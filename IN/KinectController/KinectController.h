#pragma once
#include <functional>

#include "DllApi.h"
#include "IKinectController.h"
namespace KinectController
{
	class DLLAPI KinectController : public IKinectController
	{
	private:
		int m_instance;
		std::function<void(GestureType gesture, double diff)> gestureDetectedHandler;
		std::function<void(std::string)> speechRecognizedHandler;
		std::function<void(float pitch, float roll, float yaw)> headTrackedHandler;
	public:
		KinectController();
		~KinectController();

		void setGestureDetectedHandler(std::function<void(GestureType gesture, double diff)> gestureDetectedHandler);
		std::function<void(GestureType gesture, double diff)> getGestureDetectedHandler();
		void setSpeechRecognizedHandler(std::function<void(std::string)> gestureDetectedHandler);
		std::function<void(std::string)> getSpeechRecognizedHandler();
		void setHeadTrackedHandler(std::function<void(float pitch, float roll, float yaw)> headTrackedHandler);
		std::function<void(float pitch, float roll, float yaw)> getHeadTrackedHandler();
		bool initialize();
		void dispose();
	};
}