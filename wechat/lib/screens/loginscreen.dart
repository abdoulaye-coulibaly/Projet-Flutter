import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wechat/screens/home.dart';
import 'package:wechat/screens/registerscreen.dart';
import 'package:wechat/services/authsevice.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    "Sign In",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome back! \nPlease enter your details",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const LoginForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),                 
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

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre adresse email';
              }
              if (!emailRegex.hasMatch(value)) {
                return 'Veuillez entrer une adresse email valide';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Entrez votre e-mail",
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
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 67, 70, 255),
                ),
              ),
              errorBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
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
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Mot de passe",
              labelText: "Mot de passe",
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
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 67, 70, 255),
                ),
              ),
              errorBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                try {
                  await AuthService().signInWithEmailAndPassword(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Myhomepage()),
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMessage = e.message;
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
              disabledBackgroundColor: Color.fromARGB(
                255,
                67,
                70,
                255,
              ).withOpacity(0.6),
            ),

            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text("Se connecter"),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Color(0xFF757575)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComplateProfileScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Sign Up",
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

