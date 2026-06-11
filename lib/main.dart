import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'features/swing/logic/swing_cubit.dart';
import 'features/swing/services/sensor_service.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const TennisSwingAnalyzerApp());
}


class TennisSwingAnalyzerApp extends StatelessWidget {
  const TennisSwingAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return


        BlocProvider(


      create: (_) => SwingCubit(
        sensorService: SensorService(),
      ),

      child: MaterialApp(

        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,


        theme: AppTheme.lightTheme,


        initialRoute: AppRouter.swingScreen,
        routes: AppRouter.routes,
      ),
    );
  }
}
