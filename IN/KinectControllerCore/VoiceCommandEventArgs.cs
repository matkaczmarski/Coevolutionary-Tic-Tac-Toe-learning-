using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KinectControllerCore
{
    public class VoiceCommandEventArgs : EventArgs
    {
        public string Command { get; set; }
    }
}
