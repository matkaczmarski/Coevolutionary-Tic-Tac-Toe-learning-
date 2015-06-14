#include <cstdlib>
#include <string>
#include <iostream>
#include <memory>
#include <IKinectController.h>
#include <KinectController.h>

using namespace std;

int main(int argc, char* argv[])
{
	cout << "Starting CPP tester" << endl;
	unique_ptr<KinectController::IKinectController> controller;
	controller.reset(new KinectController::KinectController());
	cout << (controller->initialize() ? "True" : "False") << endl;
	controller->setGestureDetectedHandler([](KinectController::GestureType arg, double diff)
	{
		switch (arg)
		{
		case KinectController::Unknown:
			cout << "Unknown" << endl;
			break;
		case KinectController::LeftInFront:
			cout << "LeftInFront diff = " << diff << endl;
			break;
		case KinectController::RightInFront:
			cout << "RightInFront diff = " << diff << endl;
			break;
		default:
			break;
		}
	});
	controller->setSpeechRecognizedHandler([](std::string command)
	{
		cout << "Command: " << command << endl;
	});
	controller->setHeadTrackedHandler([](float pitch, float roll, float yaw)
	{
		printf("\r%+3.0f %+3.0f %+3.0f", pitch, roll, yaw);
	});
	cout << "Pitch Roll Yaw" << endl;
	while(true)
	{
		getchar();
		// application loop
	}
	controller->dispose();
	system("pause");
	return 0;
}