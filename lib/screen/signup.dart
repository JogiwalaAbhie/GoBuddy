import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:gobuddy/screen/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../const.dart';
import '../pages/navigation_page.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {

  bool isobs = true;

  bool isload= false;

  String? errmsg;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();


  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() ?? false) {
      setState(() {
        isload=true;
      });
      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the newly created user
        User? user = userCredential.user;

        if (user != null) {

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'username': _usernameController.text.trim(),
            'phone' : _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sign up successful!")),
          );

          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));

        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          errmsg=e.message;
        });
      }
      finally{
        setState(() {
          isload=false;
        });
      }
    }
  }


  Future<void> _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isload = true;
    });

    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          isload = false;
        });
        return;
      }

      // Get authentication credentials from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential for Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Get the signed-in user's email and username
        final String email = userCredential.user!.email!;
        final String displayName = userCredential.user!.displayName ?? 'No Name';
        final String? phoneNumber = userCredential.user!.phoneNumber;

        // Store the user's information in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'username': displayName,
          'phone': phoneNumber,
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'profilePic': userCredential.user!.photoURL,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up successful!!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
      } else {
        throw Exception('User is null');
      }
    } catch (e) {
      print("Sign-up Error: ${e.toString()}");  // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isload = false;
      });
    }
  }


  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],  // Request additional phone number permission
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Authenticate with Firebase
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        String? phoneNumber = userCredential.user!.phoneNumber;

        // Store user data in Firestore (if new)
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
          'phone': phoneNumber,
          'profilePic': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up successful!!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
      }
    } catch (e) {
      print("Error during Facebook sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error:$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20,),
                    const Center(
                      child: Text("SignUp Here",
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40,color: Color(0xFF134277)),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Create an Account for your next \nall Adventures!!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35,),
                    TextFormField(
                      controller: _usernameController,
                      autocorrect: true,
                      style: const TextStyle(fontSize: 15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorText: errmsg,
                        hintText: "Username",
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
                    const SizedBox(height: 15,),
                    TextFormField(
                      controller: _phoneController,
                      autocorrect: true,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Phone Number';
                        }
                        if (value.length != 10) {
                          return 'Phone Number must be in 10 digit';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorText: errmsg,
                        hintText: "Phone",
                        hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFF134277)),
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
                    const SizedBox(height: 15,),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: true,
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
                    const SizedBox(height: 15,),
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
                          return 'Password must be at least 6 characters long';
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
                    const SizedBox(
                      height: 35,
                    ),
                    if (isload)
                      CircularProgressIndicator()
                    else
                      Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        height: 60,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(90)),
                        child: ElevatedButton(
                          onPressed: _signUp,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Color(0xFFF2F5F1),
                                fontWeight: FontWeight.bold,
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
                        const Text("Already have an Account ? ",
                          style: TextStyle(fontSize: 16,),
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
                          },
                          child: const Text("Login",
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
                      height: 30,
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
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            signInWithFacebook();
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF1877F2),
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
