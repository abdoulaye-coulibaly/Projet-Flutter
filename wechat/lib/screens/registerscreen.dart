import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wechat/screens/home.dart';
import 'package:wechat/screens/loginscreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wechat/services/authsevice.dart';

class ComplateProfileScreen extends StatelessWidget {
  const ComplateProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 67, 70, 255),
        title: const Text(
          "We.Chat",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "sign up",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete your details or continue \nwith social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const Registerform(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class Registerform extends StatefulWidget {
  const Registerform({super.key});

  @override
  State<Registerform> createState() => _RegisterformState();
}

class _RegisterformState extends State<Registerform> {
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  final confirmPasswordField = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');


  String _getMessageFromErrorCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée par un autre compte.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'operation-not-allowed':
        return 'L\'opération n\'est pas autorisée.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          TextFormField(
            controller: emailField,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!emailRegex.hasMatch(value)) {
                return 'Veuillez entrer une adresse email valide';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            suffixIcon:Icon(
                Icons.email,
                color: const Color(0xFF757575),
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
              errorBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              controller: passwordField,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "Password",
                labelText: "Password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                 suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF757575),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
                errorBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: TextFormField(
              controller: confirmPasswordField,
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                }
                if (value != passwordField.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
             
              decoration: InputDecoration(
                hintText: "Password Confirmation",
                labelText: "Password Confirmation",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                 suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF757575),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
                errorBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _isLoading
              ? const CircularProgressIndicator(
                color: Color.fromARGB(255, 67, 70, 255),
              )
              : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });

                    try {
                      await AuthService().registerWithEmailAndPassword(
                        emailField.text.trim(),
                        passwordField.text.trim(),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Myhomepage(),
                        ),
                        (route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        _errorMessage = _getMessageFromErrorCode(e);
                        _isLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        _errorMessage = 'Une erreur inattendue s\'est produite';
                        _isLoading = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromARGB(255, 67, 70, 255),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                child: const Text("Register"),
              ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("or", style: TextStyle(color: Color(0xFF757575))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Continue with social media",
                  style: TextStyle(
                    color: Color.fromARGB(255, 67, 70, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: () {
                AuthService().signInWithGoogle(context);

                },
                icon: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color.fromARGB(255, 67, 70, 255),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Color.fromARGB(255, 67, 70, 255),
                ),
              ),
             
              const Spacer(),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Color.fromARGB(255, 67, 70, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
