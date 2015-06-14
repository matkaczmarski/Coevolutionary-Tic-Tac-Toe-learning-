#pragma once

#include "DllApi.h"
#include <functional>

namespace KinectController
{
	enum DLLAPI GestureType
	{
		Unknown = 0,
		LeftInFront = 1,
		RightInFront = 2
	};

	DLLAPITEMP template class DLLAPI std::function <void(GestureType gesture, double diff)>;
	DLLAPITEMP template class DLLAPI std::function <void(std::string)>;
	// pitch: from -20 (look down)  to +20 (look up)
	// roll:  from -45 (skew right) to +45 (skew left)
	// yaw:   from -45 (look right) to +45 (look left)
	DLLAPITEMP template class DLLAPI std::function <void(float pitch, float roll, float yaw)>;

	class DLLAPI IKinectController
	{
	public:
		virtual void setGestureDetectedHandler(std::function<void(GestureType gesture, double diff)> gestureDetectedHandler)=0;
		virtual std::function<void(GestureType gesture, double diff)> getGestureDetectedHandler()=0;
		virtual void setSpeechRecognizedHandler(std::function<void(std::string)> gestureDetectedHandler)=0;
		virtual std::function<void(std::string)> getSpeechRecognizedHandler()=0;
		virtual void setHeadTrackedHandler(std::function<void(float pitch, float roll, float yaw)> headTrackedHandler)=0;
		virtual std::function<void(float pitch, float roll, float yaw)> getHeadTrackedHandler()=0;
		virtual bool initialize()=0;
		virtual void dispose()=0;
	};
}