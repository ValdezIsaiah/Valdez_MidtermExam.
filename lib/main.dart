import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        fontFamily: 'Inter',
      ),
      themeMode: _themeMode,
      home: PortfolioHome(toggleTheme: toggleTheme, themeMode: _themeMode),
    );
  }
}

class PortfolioHome extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  const PortfolioHome({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  String? currentQuote;
  String? currentAuthor;
  bool isLoadingQuote = false;
  
  String? generatedIdeas;
  bool isLoadingIdeas = false;
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchQuote(); // Load initial quote
  }

  Future<void> fetchQuote() async {
    setState(() {
      isLoadingQuote = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=motivational,technology,success'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentQuote = data['content'];
          currentAuthor = data['author'];
          isLoadingQuote = false;
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      setState(() {
        currentQuote = "The future belongs to those who believe in the beauty of their dreams.";
        currentAuthor = "Eleanor Roosevelt";
        isLoadingQuote = false;
      });
    }
  }

  Future<void> generateIdeas(String topic) async {
    if (topic.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic first!')),
      );
      return;
    }

    setState(() {
      isLoadingIdeas = true;
    });

    try {
      // Since we can't access real AI APIs without keys, I'll simulate with predefined ideas
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final List<List<String>> ideaTemplates = [
        [
          "$topic Learning Platform - An interactive web app that gamifies learning $topic with quizzes and progress tracking.",
          "$topic Community Hub - A social platform where enthusiasts can share projects, tutorials, and collaborate on $topic initiatives.",
          "Smart $topic Assistant - An AI-powered mobile app that provides personalized recommendations and tips for $topic."
        ],
        [
          "$topic Analytics Dashboard - A data visualization tool that helps users track and analyze $topic-related metrics.",
          "$topic Marketplace - An e-commerce platform specifically designed for buying/selling $topic-related products and services.",
          "$topic Virtual Reality Experience - An immersive VR application that lets users explore $topic in a 3D environment."
        ],
        [
          "$topic Automation Tool - A software solution that automates repetitive tasks in the $topic domain.",
          "$topic Mobile Game - An engaging mobile game that teaches $topic concepts through interactive gameplay.",
          "$topic Collaboration Suite - A comprehensive platform for teams working on $topic projects with real-time collaboration features."
        ]
      ];

      final random = Random();
      final selectedIdeas = ideaTemplates[random.nextInt(ideaTemplates.length)];
      
      setState(() {
        generatedIdeas = selectedIdeas.map((idea) => "• $idea").join("\n\n");
        isLoadingIdeas = false;
      });
    } catch (e) {
      setState(() {
        generatedIdeas = "• ${topic.capitalize()} Management System - A comprehensive platform for managing all aspects of $topic.\n\n• ${topic.capitalize()} Learning App - An educational mobile application focused on $topic.\n\n• ${topic.capitalize()} Analytics Tool - A data-driven solution for $topic optimization.";
        isLoadingIdeas = false;
      });
    }
  }

  Widget _buildQuoteGenerator(bool isDark) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoadingQuote)
              const CircularProgressIndicator(color: Colors.pink)
            else ...[
              Icon(
                Icons.format_quote,
                color: Colors.pink,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                currentQuote ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '— ${currentAuthor ?? 'Unknown'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.pink[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoadingQuote ? null : fetchQuote,
              icon: const Icon(Icons.refresh),
              label: Text(isLoadingQuote ? 'Loading...' : 'Generate Quote'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainstormer(bool isDark) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Enter a topic',
                hintText: 'e.g., Healthcare, Education, Gaming...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
                labelStyle: const TextStyle(color: Colors.pink),
                prefixIcon: const Icon(Icons.lightbulb, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoadingIdeas 
                ? null 
                : () => generateIdeas(_topicController.text),
              icon: isLoadingIdeas 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome),
              label: Text(isLoadingIdeas ? 'Generating...' : 'Generate Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (generatedIdeas != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Generated Project Ideas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: SingleChildScrollView(
                        child: Text(
                          generatedIdeas!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E3A8A)],
            ).colors.first,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: widget.toggleTheme,
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.yellow[400] : Colors.black,
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    'https://placehold.co/150x150/0f172a/ffffff?text=IRV',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Isaiah Royce Valdez',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Text(
                  '4th Year IT Student',
                  style: TextStyle(color: Colors.pink, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  "I'm a 4th-year Information Technology student passionate about software development, system design, and creating digital solutions that make a positive impact.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Skills Section
                _sectionTitle('Skills'),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    SkillTag('Web Development', Colors.blue),
                    SkillTag('UI/UX Design', Colors.green),
                    SkillTag('Tester', Colors.purple),
                    SkillTag('Backend', Colors.yellow),
                    SkillTag('Figma', Colors.red),
                    SkillTag('Project Management', Colors.orange),
                  ],
                ),
                const SizedBox(height: 20),

                // Projects Section
                _sectionTitle('Projects'),
                const ProjectCard(
                  title: 'UIC Library Booking System',
                  description:
                      'A digital platform that allows students to book conference rooms efficiently and paperlessly, offering a hassle-free experience with real-time room availability.',
                ),
                const ProjectCard(
                  title: 'UIC Alumni Portal',
                  description:
                      'An online system that connects and engages alumni through profiles, events, job postings, and coordinator-managed features.',
                ),
                const ProjectCard(
                  title: 'AutiSync',
                  description:
                      'A web-based application designed to support students with autism by providing accessible, structured, and safe learning experiences.',
                ),

                const SizedBox(height: 20),

                // Quote Generator Section
                _sectionTitle('💡 Quote of the Day'),
                _buildQuoteGenerator(isDark),

                const SizedBox(height: 20),

                // Brainstormer Section
                _sectionTitle('🚀 Project Brainstormer'),
                _buildBrainstormer(isDark),

                const SizedBox(height: 20),
                _sectionTitle('Get in Touch'),
                const ContactRow(
                  icon: Icons.email,
                  text: 'ivaldez_220000000293@uic.edu.ph',
                ),
                const ContactRow(
                  icon: Icons.link,
                  text: 'LinkedIn Profile',
                ),
                const ContactRow(
                  icon: Icons.code,
                  text: 'https://github.com/ValdezIsaiah',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SkillTag extends StatelessWidget {
  final String text;
  final Color color;

  const SkillTag(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color.withOpacity(0.8)),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ContactRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
