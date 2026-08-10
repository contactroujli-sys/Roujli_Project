import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';

import 'core/router/app_router.dart';
import 'core/services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OneSignalService.init(navKey: rootNavigatorKey);
  runApp(
    const ProviderScope(
      child: RoujliApp(),
    ),
  );
}

class RoujliApp extends StatelessWidget {
  const RoujliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ROUJLI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: appRouter,
        );
      },
    );
  }
}
