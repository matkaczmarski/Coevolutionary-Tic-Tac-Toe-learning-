using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KinectControllerCore
{
    public interface IKinectController : IDisposable
    {
        bool Initialize();

        event EventHandler<GestureDetectedEventArgs> GestureDetected;

        event EventHandler<VoiceCommandEventArgs> SpeechRecognized;

        event EventHandler<FaceTrackedEventArgs> FaceTracked;
    }
}
