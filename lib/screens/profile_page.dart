import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thriftin_app/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool upgrading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final auth = AuthService();
      final data = await auth.getUser();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _upgradeToCompany() async {
    try {
      setState(() => upgrading = true);
      final token = await AuthService.getToken();
      final res = await AuthService().dio.post(
        '/upgrade',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Refresh user info
      await _loadUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Akun berhasil di-upgrade ke Company!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upgrade akun.")),
      );
    } finally {
      setState(() => upgrading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 6, 6, 6),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (userData == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 16, 16),
        body: Center(child: Text("Gagal memuat data user", style: TextStyle(color: Colors.white))),
      );
    }

    final name = userData!['name'] ?? 'N/A';
    final email = userData!['email'] ?? 'N/A';
    final role = userData!['role'] ?? 'user';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Setting",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Profile Section
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 12),
                // Name
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Settings List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Email Item
                    _buildSettingsItem(
                      title: "Email",
                      subtitle: email,
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade200),
                    
                    // Role Item
                    _buildSettingsItem(
                      title: "Role",
                      subtitle: role,
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade200),
                    
                    // Touch ID Item
                    _buildSettingsItem(
                      title: "Touch ID",
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade200),
                    
                    // Languages Item
                    _buildSettingsItem(
                      title: "Languages",
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade200),
                    
                    // App information Item
                    _buildSettingsItem(
                      title: "App information",
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade200),
                    
                    // Customer care Item
                    _buildSettingsItem(
                      title: "Thriftincare care",
                      subtitle: "021-12345678",
                      onTap: () {},
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Upgrade Button
                    if (role != 'company')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 9, 9, 9),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: upgrading ? null : _upgradeToCompany,
                          child: upgrading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Upgrade ke Akun Company",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}