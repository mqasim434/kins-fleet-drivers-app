abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/';
  static const profile = '/profile';
  static const shifts = '/shifts';
  static const photos = '/photos';
  static const handovers = '/handovers';
  static const damage = '/damage';

  static String shiftDetail(String id) => '/shifts/$id';
}
