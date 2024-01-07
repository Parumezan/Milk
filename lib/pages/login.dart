import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:milk/pages/home.dart';
import 'package:milk/tools.dart';

class RegisterCard extends StatefulWidget {
  final VoidCallback changeState;

  const RegisterCard({required this.changeState, super.key});

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final LocalStorage _storage = LocalStorage(Common().localStorageName);

  String _name = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool _obscureText = true;

  Future<http.Response> _registerRequest() {
    String baseURL = Common().baseURL;

    return http.post(
      Uri.parse('$baseURL/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': _name,
        'email': _email,
        'password': _password,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(15.0),
        child: IntrinsicHeight(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Register',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _name = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _email = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _password = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _confirmPassword = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?',
                            overflow: TextOverflow.ellipsis),
                        TextButton(
                          onPressed: widget.changeState,
                          child: const Text('Login',
                              overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_password == _confirmPassword) {
                          _registerRequest().then((value) {
                            if (value.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Successfully registered',
                                          overflow: TextOverflow.ellipsis)));
                              _storage.setItem(Common().localTokenName,
                                  jsonDecode(value.body)['token']);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Something went wrong',
                                          overflow: TextOverflow.ellipsis)));
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match',
                                      overflow: TextOverflow.ellipsis)));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                      child: const Text('Register',
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ))));
  }
}

class LoginCard extends StatefulWidget {
  final VoidCallback changeState;

  const LoginCard({required this.changeState, super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final LocalStorage _storage = LocalStorage(Common().localStorageName);

  String _email = "";
  String _password = "";
  bool _obscureText = true;

  Future<http.Response> _loginRequest() {
    String baseURL = Common().baseURL;

    return http.post(
      Uri.parse('$baseURL/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          jsonEncode(<String, String>{'email': _email, 'password': _password}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(15.0),
        child: IntrinsicHeight(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text('Login',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _email = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _password = text;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?',
                            overflow: TextOverflow.ellipsis),
                        TextButton(
                          onPressed: widget.changeState,
                          child: const Text('Register',
                              overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _loginRequest().then((value) {
                          if (value.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Successfully logged in',
                                        overflow: TextOverflow.ellipsis)));
                            _storage.setItem(Common().localTokenName,
                                jsonDecode(value.body)['token']);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Incorrect credentials',
                                        overflow: TextOverflow.ellipsis)));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                      child: const Text('Login',
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ))));
  }
}

class CardSelect extends StatefulWidget {
  const CardSelect({super.key});

  @override
  State<CardSelect> createState() => _CardSelectState();
}

class _CardSelectState extends State<CardSelect> {
  bool _cardState = false;

  void _changeState() {
    setState(() {
      _cardState = !_cardState;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cardState) {
      return RegisterCard(changeState: _changeState);
    } else {
      return LoginCard(changeState: _changeState);
    }
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[
                Colors.black,
                Colors.indigo,
                Colors.deepOrangeAccent,
              ],
            ),
          ),
          child: const Center(
            child: SizedBox(width: 400, child: CardSelect()),
          ),
        ),
      ),
    );
  }
}
