import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_services.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/chat_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertServices _alertServices;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get();
    _navigationService = getIt.get();
    _alertServices = getIt.get();
    _databaseService = getIt.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Tooltip(
            message: "Logout",
            child: IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                if (result) {
                  _alertServices.showToast(
                      text: "Successfully Logged Out!", icon: Icons.check);
                  _navigationService.pushReplacementNamed("/login");
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      body: _buildUI(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: _chatList(),
    ));
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getUserPrfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to Load Data"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ChatTile(
                        userProfile: user,
                        onTap: () async {
                          final chatExists = await _databaseService
                              .checkChatExists(
                                  _authService.user!.uid, user.uid!);
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                                _authService.user!.uid, user.uid!);
                          }
                          _navigationService.push(MaterialPageRoute(
                              builder: (context) {
                            return ChatPage(
                              chatUser: user,
                            );
                          }));
                        }),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class FeedbackPage extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();
  final GetIt getIt = GetIt.instance;
  
  @override
  Widget build(BuildContext context) {
    final AlertServices _alertServices = getIt.get();

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                // Show toast message using DelightfulToast
                _alertServices.showToast(
                  text: 'Feedback submitted',
                  icon: Icons.check,
                );
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
