@echo off
REM Create directories
mkdir lib
mkdir lib\features
mkdir lib\features\client
mkdir lib\features\client\models
mkdir lib\features\client\providers
mkdir lib\features\client\screens
mkdir lib\features\client\widgets
mkdir lib\features\vendor
mkdir lib\features\vendor\models
mkdir lib\features\vendor\providers
mkdir lib\features\vendor\screens
mkdir lib\features\vendor\widgets
mkdir lib\common
mkdir lib\common\models
mkdir lib\common\providers
mkdir lib\common\screens
mkdir lib\common\screens\onboarding
mkdir lib\common\widgets
mkdir lib\services

REM Create files
echo // main.dart > lib\main.dart
echo // client_model.dart > lib\features\client\models\client_model.dart
echo // client_provider.dart > lib\features\client\providers\client_provider.dart
echo // client_service.dart > lib\features\client\providers\client_service.dart
echo // client_dashboard.dart > lib\features\client\screens\client_dashboard.dart
echo // login_screen.dart > lib\features\client\screens\login_screen.dart
echo // client_specific_widget.dart > lib\features\client\widgets\client_specific_widget.dart
echo // vendor_model.dart > lib\features\vendor\models\vendor_model.dart
echo // vendor_provider.dart > lib\features\vendor\providers\vendor_provider.dart
echo // vendor_service.dart > lib\features\vendor\providers\vendor_service.dart
echo // vendor_dashboard.dart > lib\features\vendor\screens\vendor_dashboard.dart
echo // vendor_specific_widget.dart > lib\features\vendor\widgets\vendor_specific_widget.dart
echo // user_model.dart > lib\common\models\user_model.dart
echo // user_provider.dart > lib\common\providers\user_provider.dart
echo // auth_service.dart > lib\common\providers\auth_service.dart
echo // splash_screen.dart > lib\common\screens\splash_screen.dart
echo // onboarding_screen1.dart > lib\common\screens\onboarding\onboarding_screen1.dart
echo // onboarding_screen2.dart > lib\common\screens\onboarding\onboarding_screen2.dart
echo // onboarding_screen3.dart > lib\common\screens\onboarding\onboarding_screen3.dart
echo // custom_button.dart > lib\common\widgets\custom_button.dart
echo // app_bar.dart > lib\common\widgets\app_bar.dart
echo // loading_indicator.dart > lib\common\widgets\loading_indicator.dart
echo // api_service.dart > lib\services\api_service.dart

echo Directory structure and files created successfully!
pause
