#include "in_scene.h"
#include "mini_xfileLoader.h"
#include "mini_effectLoader.h"
#include "mini_exceptions.h"
#include "dinput.h"
#include <sstream>
#include <Windowsx.h>
#include <cstdlib>
#include <string>
#include <iostream>
#include <memory>
#include <IKinectController.h>
#include <KinectController.h>

#define KEY_W 0x57
#define KEY_S 0x53
#define KEY_A 0x41
#define KEY_D 0x44
#define KEY_E 0x45

using namespace std;
using namespace mini;
using namespace mini::utils;
using namespace DirectX;

bool isKeyWPressed = false;
bool isKeySPressed = false;
bool isKeyAPressed = false;
bool isKeyDPressed = false;
bool isKeyEPressed = false;

bool movingForward = false;
bool movingBack = false;
double movingDiff = 0;

bool keyEChange = false;

bool isMouseLeftButtonPressed = false;

bool mousePositionSet = false;
int mouseXPosition = 0;
int mouseYPosition = 0;


IDirectInput8* di;
IDirectInputDevice8* pMouse;
IDirectInputDevice8* pKeyboard;

const unsigned int GET_STATE_RETRIES = 2;
const unsigned int ACQUIRE_RETRIES = 2;

float lastXRotate = 0;
float lastYRotate = 0;

unique_ptr<KinectController::IKinectController> controller;

bool INScene::ProcessMessage(WindowMessage& msg)
{
	/*Process windows messages here*/
	/*if message was processed, return true and set value to msg.result*/

	/*switch(msg.message)
	{
		case WM_KEYDOWN:
			switch (msg.wParam)
			{
				case KEY_W:
					isKeyWPressed = true;
					break;
				case KEY_S:
					isKeySPressed = true;
					break;
				case KEY_A:
					isKeyAPressed = true;
					break;
				case KEY_D:
					isKeyDPressed = true;
					break;
				case KEY_E:
					if (!isKeyEPressed)
						keyEChange = true;
					else
						keyEChange = false;
					isKeyEPressed = true;
					break;
			}
			break;
		case WM_KEYUP:
			switch (msg.wParam)
			{
				case KEY_W:
					isKeyWPressed = false;
					break;
				case KEY_S:
					isKeySPressed = false;
					break;
				case KEY_A:
					isKeyAPressed = false;
					break;
				case KEY_D:
					isKeyDPressed = false;
					break;
				case KEY_E:
					if (isKeyEPressed)
						keyEChange = true;
					else
						keyEChange = false;
					isKeyEPressed = false;
					break;
			}
		case WM_LBUTTONDOWN:
			isMouseLeftButtonPressed = true;
			break;
		case WM_LBUTTONUP:
			isMouseLeftButtonPressed = false;
			break;
		case WM_MOUSEMOVE:
			if (mousePositionSet)
			{
				if (isMouseLeftButtonPressed)
				{
					int dy = GET_X_LPARAM(msg.lParam) - mouseXPosition;
					int dx = GET_Y_LPARAM(msg.lParam) - mouseYPosition;

					float scale = 0.002f;
					m_camera.Rotate((float)dx * scale, (float)dy * scale);
				}
			}
			else
				mousePositionSet = true;
			mouseXPosition = GET_X_LPARAM(msg.lParam);
			mouseYPosition = GET_Y_LPARAM(msg.lParam);
			break;
	}

	if (isKeyEPressed)
		if (FacingDoor() && (DistanceToDoor() < 2))
		{
			isKeyEPressed = false;
			ToggleDoor();
		}*/

	return false;
}

void INScene::InitializeInput()
{
	/*Initialize Direct Input resources here*/
	//HRESULT result = DirectInput8Create(getHandle(), DIRECTINPUT_VERSION, IID_IDirectInput8, reinterpret_cast<void**>(&di), nullptr);
	/*result = di->CreateDevice(GUID_SysMouse, &pMouse, nullptr);
	result = di->CreateDevice(GUID_SysKeyboard, &pKeyboard, nullptr);
	result = pMouse->SetDataFormat(&c_dfDIMouse);
	result = pKeyboard->SetDataFormat(&c_dfDIKeyboard);
	result = pMouse->SetCooperativeLevel(m_window.getHandle(), DISCL_FOREGROUND | DISCL_NONEXCLUSIVE);	result = pKeyboard->SetCooperativeLevel(m_window.getHandle(), DISCL_FOREGROUND | DISCL_NONEXCLUSIVE);	result = pMouse->Acquire();	result = pKeyboard->Acquire();*/

	controller.reset(new KinectController::KinectController());
	cout << (controller->initialize() ? "True" : "False") << endl;
	controller->setGestureDetectedHandler([this](KinectController::GestureType arg, double diff)
	{
		this->HandleGesture(arg, diff);
	});
	controller->setSpeechRecognizedHandler([this](std::string command)
	{
		this->HandleSpeech(command);
	});
	controller->setHeadTrackedHandler([this](float pitch, float roll, float yaw)
	{
		this->HandleHeadTracking(pitch, roll, yaw);
	});
}

void INScene::HandleHeadTracking(float pitch, float roll, float yaw)
{
	int dx = 0;
	int dy = 0;
	if (roll > 15 || roll < -15)
		MoveCharacter(-0.1 * roll / 60, 0);

	if (yaw > 15 || yaw < -15)
		dy = -yaw;

	if (pitch > 10 || pitch < -10)
		dx = -pitch;

	if (dx != 0 || dy != 0)
	{
		float scale = 0.002f;
		m_camera.Rotate((float)dx * scale, (float)dy * scale);
	}

}

void INScene::HandleSpeech(std::string command)
{
	if (!FacingDoor())
		return;
	if (command == "open")
		OpenDoor();
	else if (command == "close")
		CloseDoor();
}

void INScene::HandleGesture(KinectController::GestureType gesture, double diff)
{
	switch (gesture)
	{
	case KinectController::Unknown:
		movingBack = false;
		movingForward = false;
		break;
	case KinectController::LeftInFront:
		//cout << "LeftInFront diff = " << diff << endl;
		MoveCharacter(0, -0.1 * diff);
		movingForward = false;
		movingBack = true;
		break;
	case KinectController::RightInFront:
		//cout << "RightInFront diff = " << diff << endl;
		MoveCharacter(0, 0.1 * diff);
		movingForward = true;
		movingBack = false;
		break;
	default:
		break;
	}
	movingDiff = diff;
}

/*bool GetDeviceState(IDirectInputDevice8* pDevice, unsigned int size, void* ptr)
{
	if (!pDevice)
	return false;
	for (int i = 0; i < GET_STATE_RETRIES; ++i)
	{
		HRESULT result = pDevice->GetDeviceState(size, ptr);
		if (SUCCEEDED(result))
			return true;
		if (result != DIERR_INPUTLOST && result != DIERR_NOTACQUIRED)
			throw 20; //error! throw exeption
		for (int j = 0; j < ACQUIRE_RETRIES; ++j)
		{
			result = pDevice->Acquire();
			if (SUCCEEDED(result))
			break;
			if (result != DIERR_INPUTLOST && result != E_ACCESSDENIED)
				throw 20; //error! throw exeption
		}
	}
	return false;
}*/

void INScene::Shutdown()
{
	/*Release Direct Input resources here*/

	/*pMouse->Unacquire();
	pMouse->Release();	pKeyboard->Unacquire();
	pKeyboard->Release();
	di->Release();*/

	m_font.reset();
	m_fontFactory.reset();
	m_sampler.reset();
	m_texturedEffect.reset();
	m_cbProj.reset();
	m_cbView.reset();
	m_cbModel.reset();
	m_sceneGraph.reset();
	DxApplication::Shutdown();
}


void INScene::Update(float dt)
{
	/*proccess Direct Input here*/
	
	/*remove the following line to stop the initial camera animation*/
	//m_camera.Rotate(0.0f, dt*XM_PIDIV4);

	/*DIMOUSESTATE state;
	if (GetDeviceState(pMouse, sizeof(DIMOUSESTATE), &state))
	{
		if (state.rgbButtons[0] != 0)
			isMouseLeftButtonPressed = true;
		else
			isMouseLeftButtonPressed = false;

		if (mousePositionSet)
			{
				if (isMouseLeftButtonPressed)
				{
					int dx = state.lY - mouseYPosition;
					int dy = state.lX - mouseXPosition;

					float scale = 0.002f;
					//lastXRotate += (float)dx * scale;
					//lastYRotate += (float)dy * scale;
					m_camera.Rotate((float)dx * scale, (float)dy * scale);
				}
			}
		else
			mousePositionSet = true;
		mouseXPosition = state.lY;
		mouseYPosition = state.lX;
	}

	BYTE stateK[256];
	if (GetDeviceState(pKeyboard, sizeof(BYTE)*256, stateK))
	{
		if (stateK[DIK_W] != 0)
			isKeyWPressed = true;
		else
			isKeyWPressed = false;

		if (stateK[DIK_S] != 0)
			isKeySPressed = true;
		else
			isKeySPressed = false;

		if (stateK[DIK_A] != 0)
			isKeyAPressed = true;
		else
			isKeyAPressed = false;

		if (stateK[DIK_D] != 0)
			isKeyDPressed = true;
		else
			isKeyDPressed = false;

		if (stateK[DIK_E] != 0)
			isKeyEPressed = true;
		else
			isKeyEPressed = false;

		if (isKeyEPressed)
			if (FacingDoor() && (DistanceToDoor() < 2))
			{
				isKeyEPressed = false;
				ToggleDoor();
			}
	}
	
	if (isKeyWPressed)
		MoveCharacter(0, 3 * dt);
	if (isKeySPressed)
		MoveCharacter(0, -3 * dt);
	if (isKeyAPressed)
		MoveCharacter(-3 * dt, 0);
	if (isKeyDPressed)
		MoveCharacter(3 * dt, 0);*/

	m_counter.NextFrame(dt);
	UpdateDoor(dt);
}

void INScene::RenderText()
{
	wstringstream str;
	str << L"FPS: " << m_counter.getCount();
	m_font->DrawString(m_context.get(), str.str().c_str(), 20.0f, 10.0f, 10.0f, 0xff0099ff, FW1_RESTORESTATE|FW1_NOGEOMETRYSHADER);
	if (DistanceToDoor() < 1.0f && FacingDoor())
	{
		wstring prompt(L"(E) Otwórz/Zamknij");
		FW1_RECTF layout;
		auto rect = m_font->MeasureString(prompt.c_str(), L"Calibri", 20.0f, &layout, FW1_NOWORDWRAP);
		float width = rect.Right - rect.Left;
		float height = rect.Bottom - rect.Top;
		auto clSize = m_window.getClientSize();
		m_font->DrawString(m_context.get(), prompt.c_str(), 20.0f, (clSize.cx - width)/2, (clSize.cy - height)/2, 0xff00ff99,  FW1_RESTORESTATE|FW1_NOGEOMETRYSHADER);
	}
	if (movingForward || movingBack)
	{
		wstringstream str2;
		str2 << L"diff: " << movingDiff;
		m_font->DrawString(m_context.get(), str2.str().c_str(), 20.0f, 10.0f, 40.0f, 0xff0099ff, FW1_RESTORESTATE | FW1_NOGEOMETRYSHADER);
	}
}

bool INScene::Initialize()
{
	if (!DxApplication::Initialize())
		return false;
	XFileLoader xloader(m_device);
	xloader.Load("house.x");
	m_sceneGraph.reset(new SceneGraph(move(xloader.m_nodes), move(xloader.m_meshes), move(xloader.m_materials)));

	m_doorNode = m_sceneGraph->nodeByName("Door");
	m_doorTransform = m_sceneGraph->getNodeTransform(m_doorNode);
	m_doorAngle = 0;
	m_doorAngVel = -XM_PIDIV2;

	m_cbProj.reset(new ConstantBuffer<XMFLOAT4X4>(m_device));
	m_cbView.reset(new ConstantBuffer<XMFLOAT4X4>(m_device));
	m_cbModel.reset(new ConstantBuffer<XMFLOAT4X4, 2>(m_device));
	m_cbMaterial.reset(new ConstantBuffer<Material::MaterialData>(m_device));

	EffectLoader eloader(m_device);
	eloader.Load(L"textured.hlsl");
	m_texturedEffect.reset(new TexturedEffect(move(eloader.m_vs), move(eloader.m_ps), m_cbProj, m_cbView, m_cbModel, m_cbMaterial));
	D3D11_INPUT_ELEMENT_DESC elem[] = 
	{
		{ "POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 },
		{ "NORMAL", 0, DXGI_FORMAT_R32G32B32_FLOAT, 1, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 },
		{ "TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 2, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 }
	};
	m_layout = m_device.CreateInputLayout(elem, 3, eloader.m_vsCode);

	SIZE s = m_window.getClientSize();
	float ar = static_cast<float>(s.cx) / s.cy;
	XMStoreFloat4x4(&m_proj, XMMatrixPerspectiveFovLH(XMConvertToRadians(60.0f), ar, 0.01f, 100.0f));
	m_cbProj->Update(m_context, m_proj);

	vector<OrientedBoundingRectangle> obstacles;
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(-3.0f, 3.8f), 6.0f, 0.2f, 0.0f));
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(-3.0f, -4.0f), 6.0f, 0.2f, 0.0f));
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(2.8f, -3.8f), 0.2f, 7.6f, 0.0f));
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(-3.0f, -3.8f), 0.2f, 4.85f, 0.0f));
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(-3.0f, 1.95f), 0.2f, 1.85f, 0.0f));
	obstacles.push_back(OrientedBoundingRectangle(XMFLOAT2(-3.05f, 1.0f), 0.1f, 1.0f, 0.0f));
	m_collisions.SetObstacles(move(obstacles));

	RasterizerDescription rsDesc;
	m_rsState = m_device.CreateRasterizerState(rsDesc);
	SamplerDescription sDesc;
	m_sampler = m_device.CreateSamplerState(sDesc);
	ID3D11SamplerState* sstates[1] = { m_sampler.get() };
	m_context->PSSetSamplers(0, 1, sstates);
	
	IFW1Factory *pf;
	HRESULT result = FW1CreateFactory(FW1_VERSION, &pf);
	m_fontFactory.reset(pf);
	if (FAILED(result))
		THROW_DX11(result);
	IFW1FontWrapper *pfw;
	result = m_fontFactory->CreateFontWrapper(m_device.getDevicePtr(), L"Calibri", &pfw);
	m_font.reset(pfw);
	if (FAILED(result))
		THROW_DX11(result);

	InitializeInput();
	return true;
}

void INScene::Render()
{
	if (!m_context)
		return;
	DxApplication::Render();
	m_context->RSSetState(m_rsState.get());
	XMFLOAT4X4 mtx[2];
	XMStoreFloat4x4(&mtx[0], m_camera.GetViewMatrix());
	m_cbView->Update(m_context, mtx[0]);
	m_texturedEffect->Begin(m_context);
	for ( unsigned int i = 0; i < m_sceneGraph->meshCount(); ++i)
	{
		Mesh& m = m_sceneGraph->getMesh(i);
		Material& material = m_sceneGraph->getMaterial(m.getMaterialIdx());
		if (!material.getDiffuseTexture())
			continue;
		ID3D11ShaderResourceView* srv[2] = { material.getDiffuseTexture().get(), material.getSpecularTexture().get() };
		m_context->PSSetShaderResources(0, 2, srv);
		mtx[0] = m.getTransform();
		XMMATRIX modelit = XMLoadFloat4x4(&mtx[0]);
		XMVECTOR det;
		modelit = XMMatrixTranspose(XMMatrixInverse(&det, modelit));
		XMStoreFloat4x4(&mtx[1], modelit);
		m_cbMaterial->Update(m_context, material.getMaterialData());
		m_cbModel->Update(m_context, mtx);
		m_context->IASetInputLayout(m_layout.get());
		m.Render(m_context);
	}
	RenderText();
}

void INScene::OpenDoor()
{
	if (m_doorAngVel < 0)
		m_doorAngVel = -m_doorAngVel;
}

void INScene::CloseDoor()
{
	if (m_doorAngVel > 0)
		m_doorAngVel = -m_doorAngVel;
}

void INScene::ToggleDoor()
{
	m_doorAngVel = -m_doorAngVel;
}

void INScene::UpdateDoor(float dt)
{
	if ((m_doorAngVel > 0 && m_doorAngle < XM_PIDIV2) || (m_doorAngVel < 0 && m_doorAngle > 0))
	{
		m_doorAngle += dt*m_doorAngVel;
		if ( m_doorAngle < 0 )
			m_doorAngle = 0;
		else if (m_doorAngle > XM_PIDIV2)
			m_doorAngle = XM_PIDIV2;
		XMFLOAT4X4 doorTransform;
		XMMATRIX mtx = XMLoadFloat4x4(&m_doorTransform);
		XMVECTOR v = XMVectorSet(0.000004f, 0.0f, -1.08108f, 1.0f);
		v = XMVector3TransformCoord(v, mtx);
		XMStoreFloat4x4(&doorTransform, mtx*XMMatrixTranslationFromVector(-v)*XMMatrixRotationZ(m_doorAngle)*XMMatrixTranslationFromVector(v));
		m_sceneGraph->setNodeTransform(m_doorNode, doorTransform);
		XMFLOAT2 tr = m_collisions.MoveObstacle(5, OrientedBoundingRectangle(XMFLOAT2(-3.05f, 1.0f), 0.1f, 1.0f, m_doorAngle));
		m_camera.Move(XMFLOAT3(tr.x, 0, tr.y));
	}
}

void INScene::MoveCharacter(float dx, float dz)
{
	XMVECTOR forward = m_camera.getForwardDir();
	XMVECTOR right = m_camera.getRightDir();
	XMFLOAT3 temp;
	XMStoreFloat3(&temp, forward*dz + right*dx);
	XMFLOAT2 tr = XMFLOAT2(temp.x, temp.z);
	m_collisions.MoveCharacter(tr);
	m_camera.Move(XMFLOAT3(tr.x, 0, tr.y));
}

bool INScene::FacingDoor()
{
	auto rect = m_collisions.getObstacle(5);
	XMVECTOR points[4] = { XMLoadFloat2(&rect.getP1()), XMLoadFloat2(&rect.getP2()), XMLoadFloat2(&rect.getP3()), XMLoadFloat2(&rect.getP4()) };
	XMVECTOR forward = XMVectorSwizzle(m_camera.getForwardDir(), 0, 2, 1, 3);
	XMVECTOR camera = XMVectorSwizzle(XMLoadFloat4(&m_camera.getPosition()), 0, 2, 1, 3);
	unsigned int max_i = 0, max_j = 0;
	float max_a = 0.0f;
	for (unsigned int i = 0; i < 4; ++i)
	{
		for (unsigned int j = i + 1; j < 4; ++j)
		{
			float a = XMVector2AngleBetweenVectors(points[i]-camera, points[j]-camera).m128_f32[0];
			if (a > max_a)
			{
				max_i = i;
				max_j = j;
				max_a = a;
			}
		}
	}
	return XMScalarNearEqual(XMVector2AngleBetweenVectors(forward, points[max_i]-camera).m128_f32[0] + XMVector2AngleBetweenVectors(forward, points[max_j] - camera).m128_f32[0], max_a, 0.001f);
}

float INScene::DistanceToDoor()
{
	return m_collisions.DistanceToObstacle(5);
}