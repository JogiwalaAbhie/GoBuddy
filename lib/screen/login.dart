import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:gobuddy/Admin/admin_home.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/const.dart';
import 'package:gobuddy/screen/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import '../pages/navigation_page.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  bool isobs = true;

  bool isload= false;

  String? errmsg;

  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  Future<void> _login() async {
    if (formKey.currentState!.validate() ?? false) {
      setState(() {
        isload=true;
      });
      try {
        // Log in with email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (doc.exists) {
          String emailid = doc['email'];// Get user role

          if (emailid == "admin@gobuddy.com") {
            // Navigate to Admin Panel
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNavigationPage()));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Admin Login successful!")),
            );
          } else {
            // Navigate to user Panel
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login successful!")),
            );


          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not found")),
          );
        }


      } on FirebaseAuthException catch (e) {
        setState(() {
          errmsg="Either Email or Password are Wrong!";
        });
      }
      finally{
        setState(() {
          isload=false;
        });
      }
    }
  }

  Future<User?> _signInWithGoogle() async {
    setState(() {
      isload = true;
    });

    try {
      GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          isload = false;
        });
        return null;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists) {
          // User exists → Login successful
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome back, ${userData['username']}!")),
          );
        } else {
          // User does not exist → Register in Firestore
          await userDocRef.set({
            'username': user.displayName ?? "Unknown",
            'email': user.email ?? "No Email",
            'phone': user.phoneNumber ?? "N/A",
            'uid': user.uid,
            'role':'user',
            'profilePic': user.photoURL ?? "",
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account created successfully!")),
          );
        }

        // Navigate to home page after login or registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
        );
      }

      return user;
    } catch (e) {
      print("Error during Google Sign-In: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );

      return null;
    } finally {
      setState(() {
        isload = false;
      });
    }
  }

  Future<void> signInWithFacebook() async {
    setState(() {
      isload = true;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Authenticate with Firebase
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

          DocumentSnapshot userDoc = await userDocRef.get();

          if (userDoc.exists) {
            // User exists → Login successful
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Welcome back, ${userData['username']}!")),
            );
          } else {
            // User does not exist → Register them in Firestore
            await userDocRef.set({
              'username': user.displayName ?? "Unknown",
              'email': user.email ?? "No Email",
              'phone': user.phoneNumber ?? "No Phone",
              'uid': user.uid,
              'role':'user',
              'profilePic': user.photoURL ?? "",
              'createdAt': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Account created successfully!")),
            );
          }

          // Navigate to home page after login or registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigationPage()),
          );
        }
      }
    } catch (e) {
      print("Error during Facebook sign-in: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30,),
                  const Center(
                    child: Text("Login Here",
                      style: TextStyle(fontWeight: FontWeight.w700,fontSize: 40,color: Color(0xFF134277)),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome back you've been\n missed!!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40,),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 15),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: true,
                    enableSuggestions: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex =
                      RegExp(r'^[^@]+@[^@]+\.[^@]+'); // Basic email validation
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      errorText: errmsg,
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF134277)),
                      filled: true,
                      fillColor: const Color(0xFFBFCFF3),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontSize: 15),
                    obscureText: isobs,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      errorText: errmsg,
                      suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              isobs = !isobs;
                            });
                          },
                          icon: Icon(
                            isobs ? Icons.visibility : Icons.visibility_off
                          )
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                      prefixIcon: const Icon(Icons.security, color: Color(0xFF134277)),
                      filled: true,
                      fillColor: const Color(0xFFBFCFF3),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => forgotpass()));
                        },
                        child: const Text("Forgot Password?",
                          style: TextStyle(fontWeight: FontWeight.w500,color: Color(0xFF134277)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (isload)
                    Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        height: 90,
                        child: Lottie.asset("assets/animation/loadwithplane.json")
                    )
                  else
                    Container(
                      width: MediaQuery.of(context).size.width*0.8,
                      height: 60,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(90)),
                      child: ElevatedButton(
                        onPressed: _login,
                        child: Text(
                          'Login',
                          style: const TextStyle(
                              color: Color(0xFFF2F5F1),
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black,
                          backgroundColor: const Color(0xFF134277),
                          elevation: 10, // Elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an Account ? ",
                        style: TextStyle(fontSize: 16,),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => signup()));
                        },
                        child: const Text("Sign Up",
                          style: TextStyle(
                            color: Color(0xFF1371CE),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Or continue with",
                        style: TextStyle(color: blueTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Button
                      GestureDetector(
                        onTap: () {
                          _signInWithGoogle();
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/image/google.webp', // Replace with your Google icon
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Spacing between buttons
                      // Facebook Button
                      GestureDetector(
                        onTap: () {
                          signInWithFacebook();
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.facebook,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}

class forgotpass extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<forgotpass> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        setState(() {
          _errorMessage = null;
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      'Reset Your Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF134277),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Subtitle
                    const Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 32.0),
                    // Email input
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _emailController,
                        autocorrect: true,
                        style: const TextStyle(fontSize: 15),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex =
                          RegExp(r'^[^@]+@[^@]+\.[^@]+'); // Basic email validation
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          errorText: _errorMessage,
                          hintText: "E-mail",
                          hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF134277)),
                          filled: true,
                          fillColor: const Color(0xFFBFCFF3),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    // Error message
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    const SizedBox(height: 32.0),
                    // Submit button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _sendPasswordResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF134277),
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Back to Login Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to login screen
                      },
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(fontSize: 16, color: Color(0xFF134277),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


