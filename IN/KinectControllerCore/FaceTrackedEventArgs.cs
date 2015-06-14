using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KinectControllerCore
{
    public class FaceTrackedEventArgs : EventArgs
    {
        public float Pitch { get; set; }

        public float Roll { get; set; }

        public float Yaw { get; set; }
    }
}
