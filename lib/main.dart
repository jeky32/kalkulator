import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator App',
      theme: ThemeData(
        primarySwatch: Colors.green, // Mode terang
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green, // Mode gelap
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Mengikuti pengaturan sistem
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/profil': (context) => ProfilPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/riwayat') {
          final List<String> history = settings.arguments as List<String>;
          return MaterialPageRoute(
            builder: (context) {
              return RiwayatPage(history: history);
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String input = '';
  List<String> history = [];
  bool isDarkMode = false;

  // Tambahkan karakter ke dalam input
  void appendInput(String value) {
    setState(() {
      input += value;
    });
  }

  // Hapus seluruh input
  void clearInput() {
    setState(() {
      input = '';
    });
  }

  // Hapus satu karakter terakhir
  void deleteLastInput() {
    setState(() {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    });
  }

  // Hitung hasil ekspresi matematika
  void calculateResult() {
    try {
      final result = _evaluateExpression(input);
      setState(() {
        history.add('$input = $result');
        input = result.toString();
      });
    } catch (e) {
      setState(() {
        input = 'Error';
      });
    }
  }

  // Evaluasi ekspresi menggunakan math_expressions
  double _evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      throw Exception("Invalid operation");
    }
  }

  // Toggle mode gelap dan terang
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
        leading: Icon(Icons.calculate),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2), // Ganti warna border menjadi hijau
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(minHeight: 40, minWidth: 150, maxHeight: 60, maxWidth: 250), // Perkecil ukuran BoxConstraints
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    input,
                    style: TextStyle(fontSize: 32, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildButtonRow(['7', '8', '9', '÷']),
              _buildButtonRow(['4', '5', '6', '×']),
              _buildButtonRow(['1', '2', '3', '-']),
              _buildButtonRow(['C', '0', '⌫', '+']),
              _buildButtonRow(['=']),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Kalkulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/profil');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/riwayat', arguments: history);
          }
        },
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: labels.map((label) => _buildButton(label)).toList(),
    );
  }

  Widget _buildButton(String label) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () {
          if (label == 'C') {
            clearInput();
          } else if (label == '⌫') {
            deleteLastInput();
          } else if (label == '=') {
            calculateResult();
          } else {
            appendInput(label);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: label == '=' ? Colors.orange : (isDarkMode ? Colors.white : Colors.black), // Ganti warna tombol '=' menjadi oranye
          foregroundColor: isDarkMode ? Colors.black : Colors.white, // Warna teks tombol
          minimumSize: Size(70, 70), // Perbesar ukuran tombol
          shape: CircleBorder(), // Membuat tombol berbentuk bulat
        ),
        child: Text(label, style: TextStyle(fontSize: 20)), // Perbesar ukuran teks
      ),
    );
  }
}

class RiwayatPage extends StatelessWidget {
  final List<String> history;

  RiwayatPage({required this.history});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat'),
        leading: Icon(Icons.history),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              if (isDarkMode) {
                Theme.of(context).brightness == Brightness.light;
              } else {
                Theme.of(context).brightness == Brightness.dark;
              }
            },
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                history[index],
                style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Kalkulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/profil');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/riwayat', arguments: history);
          }
        },
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        leading: Icon(Icons.person),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Ganti URL dengan URL gambar profil Anda
            ),
            SizedBox(height: 20),
            Text('Nama: Zacky Noor Faizi', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Kelas: XI RPL 2', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Kalkulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/profil');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/riwayat');
          }
        },
      ),
    );
  }
}