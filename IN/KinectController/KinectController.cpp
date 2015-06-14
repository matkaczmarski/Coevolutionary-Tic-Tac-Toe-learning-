// This is the main DLL file.

#include "stdafx.h"

namespace KinectController
{
	ref class GestureHandler
	{
	public:
		KinectController* target;
		void OnGestureDetected(System::Object ^sender, KinectControllerCore::GestureDetectedEventArgs ^e);
	};

	ref class SpeechHandler
	{
	public:
		KinectController* target;
		void OnSpeechRecognized(System::Object ^sender, KinectControllerCore::VoiceCommandEventArgs ^e);
	};

	ref class HeadHandler
	{
	public:
		KinectController* target;
		void OnHeadTracked(System::Object ^sender, KinectControllerCore::FaceTrackedEventArgs ^e);
	};

	KinectController::KinectController()
	{
		m_instance = KinectControllerCore::KinectController::NewInstance();

		GestureHandler^ gestureHandler = gcnew GestureHandler();
		gestureHandler->target = this;
		KinectControllerCore::KinectController::GetInstance(m_instance)->GestureDetected += gcnew System::EventHandler<KinectControllerCore::GestureDetectedEventArgs ^>(gestureHandler, &GestureHandler::OnGestureDetected);

		SpeechHandler^ speechHandler = gcnew SpeechHandler();
		speechHandler->target = this;
		KinectControllerCore::KinectController::GetInstance(m_instance)->SpeechRecognized += gcnew System::EventHandler<KinectControllerCore::VoiceCommandEventArgs ^>(speechHandler, &SpeechHandler::OnSpeechRecognized);

		HeadHandler^ headHandler = gcnew HeadHandler();
		headHandler->target = this;
		KinectControllerCore::KinectController::GetInstance(m_instance)->FaceTracked += gcnew System::EventHandler<KinectControllerCore::FaceTrackedEventArgs ^>(headHandler, &HeadHandler::OnHeadTracked);
	}

	KinectController::~KinectController()
	{
		KinectControllerCore::KinectController^ intController = KinectControllerCore::KinectController::GetInstance(m_instance);
		if (intController != nullptr)
			intController->~KinectController();
	}

	bool KinectController::initialize()
	{
		KinectControllerCore::KinectController^ intController = KinectControllerCore::KinectController::GetInstance(m_instance);
		bool result = false;
		try
		{
			result = intController->Initialize();
		}
		catch (std::exception exc)
		{
			printf("%s\n", exc.what());
		}
		catch (System::Exception^ exc)
		{
			printf("%s\n", cstr(exc->Message).c_str());
		}
		return result;
	}

	void KinectController::dispose()
	{
		KinectControllerCore::KinectController^ intController = KinectControllerCore::KinectController::GetInstance(m_instance);
		intController->~KinectController();
	}

	void KinectController::setGestureDetectedHandler(std::function<void(GestureType gesture, double diff)> gestureDetectedHandler)
	{
		this->gestureDetectedHandler = gestureDetectedHandler;
	}

	std::function<void(GestureType gesture, double diff)> KinectController::getGestureDetectedHandler()
	{
		return gestureDetectedHandler;
	}

	void KinectController::setSpeechRecognizedHandler(std::function<void(std::string)> handler)
	{
		this->speechRecognizedHandler = handler;
	}

	std::function<void(std::string)> KinectController::getSpeechRecognizedHandler()
	{
		return speechRecognizedHandler;
	}

	void KinectController::setHeadTrackedHandler(std::function<void(float p, float r, float y)> handler)
	{
		this->headTrackedHandler = handler;
	}
	std::function<void(float, float, float)> KinectController::getHeadTrackedHandler()
	{
		return this->headTrackedHandler;
	}

	void GestureHandler::OnGestureDetected(System::Object ^sender, KinectControllerCore::GestureDetectedEventArgs ^e)
	{
		if (target->getGestureDetectedHandler())
			target->getGestureDetectedHandler()((GestureType)e->Gesture, e->Diff);
	}

	void SpeechHandler::OnSpeechRecognized(System::Object ^sender, KinectControllerCore::VoiceCommandEventArgs ^e)
	{
		if (target->getSpeechRecognizedHandler())
			target->getSpeechRecognizedHandler()(cstr(e->Command));
	}

	void HeadHandler::OnHeadTracked(System::Object ^sender, KinectControllerCore::FaceTrackedEventArgs ^e)
	{
		if (target->getHeadTrackedHandler())
			target->getHeadTrackedHandler()(e->Pitch, e->Roll, e->Yaw);
	}
}