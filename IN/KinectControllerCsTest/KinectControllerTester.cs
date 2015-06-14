using KinectControllerCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KinectControllerCsTest
{
    class KinectControllerTester
    {
        public static void Main()
        {
            using (IKinectController controller = KinectController.GetInstance(KinectController.NewInstance()))
            {
                if (!controller.Initialize())
                {
                    return;
                }
                Console.WriteLine();
                controller.FaceTracked += (s, e) =>
                    {
                        Console.Write("\r{0,4:###} {1,4:###} {2,4:###}", e.Pitch, e.Roll, e.Yaw);
                    };
                controller.SpeechRecognized += controller_SpeechRecognized;
                controller.PostureDetected += controller_PostureDetected;
                Console.WriteLine("Started");
                Console.WriteLine("Pitch Roll Yaw");
                while(true)
                {
                    Console.ReadLine();
                }
            }
        }

        static void controller_PostureDetected(object sender, PostureDetectedEventArgs e)
        {
            Console.WriteLine(e.Posture);
        }

        static void controller_SpeechRecognized(object sender, VoiceCommandEventArgs e)
        {
            Console.WriteLine(e.Command);
        }
    }
}
