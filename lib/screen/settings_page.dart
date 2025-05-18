import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatter/fun/appInter.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  final Locale currentLocale;

  const SettingsPage({
    Key? key,
    required this.onLocaleChange,
    required this.currentLocale,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _ctrlOld = TextEditingController();
  final _ctrlNew = TextEditingController();
  bool _isProcessing = false;

  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

  Future<void> _changePassword() async {
    if (user == null) return;
    final oldPass = _ctrlOld.text.trim();
    final newPass = _ctrlNew.text.trim();
    if (oldPass.isEmpty || newPass.isEmpty) return;

    setState(() => _isProcessing = true);

    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPass,
    );

    try {
      await user!.reauthenticateWithCredential(cred);
      await user!.updatePassword(newPass);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings(widget.currentLocale.languageCode).passwordChanged)),
      );
      _ctrlOld.clear();
      _ctrlNew.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onLocaleSelected(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    widget.onLocaleChange(locale);
  }

  @override
  void dispose() {
    _ctrlOld.dispose();
    _ctrlNew.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.currentLocale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _ctrlOld,
              obscureText: true,
              decoration: InputDecoration(
                labelText: strings.currentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrlNew,
              obscureText: true,
              decoration: InputDecoration(
                labelText: strings.newPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _changePassword,
              child: Text(strings.changePassword),
            ),
            const Divider(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.logout),
              label: Text(strings.signOut),
              onPressed: _signOut,
            ),
            const Divider(height: 40),
            Text(
              strings.selectLanguage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<Locale>(
              title: Text(strings.english),
              value: const Locale('en'),
              groupValue: _selectedLocale,
              onChanged: (locale) {
                if (locale != null) _onLocaleSelected(locale);
              },
            ),
            RadioListTile<Locale>(
              title: Text(strings.russian),
              value: const Locale('ru'),
              groupValue: _selectedLocale,
              onChanged: (locale) {
                if (locale != null) _onLocaleSelected(locale);
              },
            ),
            RadioListTile<Locale>(
              title: Text(strings.kazakh),
              value: const Locale('kk'),
              groupValue: _selectedLocale,
              onChanged: (locale) {
                if (locale != null) _onLocaleSelected(locale);
              },
            ),
          ],
        ),
      ),
    );
  }
}
