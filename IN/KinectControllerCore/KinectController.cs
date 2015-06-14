using Microsoft.Kinect;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Kinect.Toolbox;
using Kinect.Toolbox.Record;
using System.Globalization;
using System.Configuration;
using Microsoft.Speech.Recognition;
using Microsoft.Speech.AudioFormat;
using Microsoft.Kinect.Toolkit.FaceTracking;

namespace KinectControllerCore
{
    public class KinectController : IKinectController
    {
        private static List<KinectController> controllers = new List<KinectController>();
        readonly ContextTracker contextTracker = new ContextTracker();

        private List<string> lines = new List<string>();
        private int counter = 0;

        private KinectController() { }

        private KinectSensor Sensor { get; set; }

        private SpeechRecognitionEngine SpeechRecognizer { get; set; }

        private FaceTracker HeadTracker { get; set; }

        private Skeleton[] skeletons;

        public static int NewInstance()
        {
            var controller = new KinectController();
            controllers.Add(controller);
            return controllers.Count - 1;
        }

        public static KinectController GetInstance(int index)
        {
            if (!controllers.Any())
                return null;
            return controllers[index];
        }

        public event EventHandler<GestureDetectedEventArgs> GestureDetected;

        public bool Initialize()
        {
            foreach (var sensor in KinectSensor.KinectSensors)
            {
                if (sensor.Status == KinectStatus.Connected)
                {
                    Sensor = sensor;
                    break;
                }
            }
            if (Sensor == null)
                return false;
            InitSensor();
            return true;
        }

        private void InitSensor()
        {
            Sensor.SkeletonStream.Enable(new TransformSmoothParameters
            {
                Smoothing = 0.5f,
                Correction = 0.5f,
                Prediction = 0.5f,
                JitterRadius = 0.05f,
                MaxDeviationRadius = 0.04f
            });
            Sensor.ColorStream.Enable();
            Sensor.DepthStream.Enable();
            Sensor.AllFramesReady += OnAllFramesReady;
            EnsureHeadTracker();
            Sensor.Start();

            SpeechRecognizer = new SpeechRecognitionEngine(new CultureInfo("en-US"));
            GrammarBuilder grammarBuilder = new GrammarBuilder();
            grammarBuilder.Culture = new CultureInfo("en-US");
            var commands = new Choices();
            commands.Add("open");
            commands.Add("close");
            grammarBuilder.Append(commands);
            SpeechRecognizer.LoadGrammar(new Grammar(grammarBuilder));
            SpeechRecognizer.SpeechRecognized += SpeechRecognizedHandler;
            SpeechRecognizer.SetInputToAudioStream(Sensor.AudioSource.Start(),
                new SpeechAudioFormatInfo(EncodingFormat.Pcm, 16000, 16, 1, 32000, 2, null));
            SpeechRecognizer.RecognizeAsync(RecognizeMode.Multiple);
        }

        void OnGestureDetected(string obj, double diff)
        {
            GestureType gesture = GestureType.Unknown;
            Enum.TryParse(obj, out gesture);
            if (GestureDetected != null)
                GestureDetected(this, new GestureDetectedEventArgs()
                {
                    Gesture = gesture,
                    Diff = diff
                });
        }

        private bool EnsureHeadTracker()
        {
            if (HeadTracker==null)
            {
                try
                {
                    HeadTracker = new FaceTracker(Sensor);
                }
                catch (InvalidOperationException)
                {
                    return false;
                }
            }
            return true;
        }

        void OnAllFramesReady(object sender, AllFramesReadyEventArgs e)
        {
            using (SkeletonFrame skeletonFrame = e.OpenSkeletonFrame())
            {
                using (var colorFrame = e.OpenColorImageFrame())
                {
                    using (var depthFrame = e.OpenDepthImageFrame())
                    {

                        if (skeletonFrame == null)
                            return;

                        skeletonFrame.GetSkeletons(ref skeletons);

                        if (!skeletons.All(s => s.TrackingState == SkeletonTrackingState.NotTracked))
                            ProcessFrame(colorFrame, depthFrame, skeletonFrame);
                    }
                }
            }
        }

        void SpeechRecognizedHandler(object sender, SpeechRecognizedEventArgs e)
        {
            if (SpeechRecognized != null)
                SpeechRecognized(this, new VoiceCommandEventArgs()
                {
                    Command = e.Result.Text
                });
        }
        
        public void Dispose()
        {
            if (Sensor != null)
                Sensor.Dispose();
            if (SpeechRecognizer != null)
                SpeechRecognizer.Dispose();
            SpeechRecognizer = null;
            Sensor = null;

            skeletons = null;

            foreach (var item in SpeechRecognized.GetInvocationList())
                SpeechRecognized -= (EventHandler<VoiceCommandEventArgs>)item;
            foreach (var item in GestureDetected.GetInvocationList())
                GestureDetected -= (EventHandler<GestureDetectedEventArgs>)item;
        }

        private void ProcessFrame(ColorImageFrame colorFrame, DepthImageFrame depthFrame, ReplaySkeletonFrame skeletonFrame)
        {
            Dictionary<int, string> stabilities = new Dictionary<int, string>();
            foreach (var skeleton in skeletonFrame.Skeletons)
            {
                if (skeleton.TrackingState != SkeletonTrackingState.Tracked)
                    continue;

                contextTracker.Add(skeleton.Position.ToVector3(), skeleton.TrackingId);
                stabilities.Add(skeleton.TrackingId, contextTracker.IsStableRelativeToCurrentSpeed(skeleton.TrackingId) ? "Stable" : "Non stable");
                if (!contextTracker.IsStableRelativeToCurrentSpeed(skeleton.TrackingId))
                    continue;

                SkeletonPoint center = skeleton.Position;
                foreach (Joint joint in skeleton.Joints)
                {
                    if (joint.JointType == JointType.HandLeft)
                    {
                        if (center.Z - joint.Position.Z > 0.25)
                            OnGestureDetected(GestureType.LeftInFront.ToString(), center.Z - joint.Position.Z);
                    }
                    else if (joint.JointType == JointType.HandRight)
                    {
                        if (center.Z - joint.Position.Z > 0.25)
                            OnGestureDetected(GestureType.RightInFront.ToString(), center.Z - joint.Position.Z);
                    }
                }

                if (EnsureHeadTracker())
                {
                    byte[] colorImage = new byte[colorFrame.PixelDataLength];
                    colorFrame.CopyPixelDataTo(colorImage);
                    short[] depthImage = new short[depthFrame.PixelDataLength];
                    depthFrame.CopyPixelDataTo(depthImage);
                    var result = HeadTracker.Track(colorFrame.Format, colorImage, depthFrame.Format, depthImage, skeleton);
                    if (result.TrackSuccessful)
                    {
                        if (FaceTracked != null)
                            FaceTracked(this, new FaceTrackedEventArgs()
                            {
                                Pitch = result.Rotation.X,
                                Roll = result.Rotation.Z,
                                Yaw = result.Rotation.Y
                            });
                    }
                }
            }
        }

        public event EventHandler<VoiceCommandEventArgs> SpeechRecognized;

        public event EventHandler<FaceTrackedEventArgs> FaceTracked;
    }
}
