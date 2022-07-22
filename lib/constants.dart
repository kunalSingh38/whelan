const String ALERT_DIALOG_TITLE = "Alert";
// const String URL = "https://wrlapp.crowdrcrm.com/api/v1/";
const String URL = "https://whelanwebapp.com/api/v1/";
const String STATIC_BARIER =
    "smVofv1bE2nfrOBRRGfep-G7ohMN9eanc4GUgTPSDYwKEjfoe5";
final String path = 'assets/images/';

class Draw {
  final String title;
  final String icon;
  Draw({this.title, this.icon});
}

final List<Draw> drawerItems = [
  Draw(title: 'Home', icon: path + 'home.png'),
  // Draw(title: 'My Account', icon: path + 'user_home.png'),
  // Draw(title: 'View Checklist', icon: path + 'checklist.png'),
  Draw(title: 'Change Password', icon: path + 'change_pass.png'),
];
