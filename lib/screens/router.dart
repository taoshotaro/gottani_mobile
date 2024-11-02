import 'package:auto_route/auto_route.dart';
import 'package:gottani_mobile/screens/router.gr.dart';

/// ルーティング設定
@AutoRouterConfig(replaceInRouteName: 'Screen,Route', deferredLoading: true)
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SampleRoute.page, initial: false),
        AutoRoute(page: InteractiveRoute.page, initial: true),
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}
