using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KinectControllerCore
{
    public enum GestureType
    {
        Unknown = 0,
        LeftInFront = 1,
        RightInFront = 2
    }

    public class GestureDetectedEventArgs
    {
        public GestureType Gesture { get; set; }
        public double Diff { get; set; }
    }
}
