import 'package:eduguide/pages/dash_board.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  List countries = [];
  List universities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final countryData = await supabase
          .from('countries')
          .select()
          .order('id')
          .limit(5);

      final universityData = await supabase
          .from('universities_home')
          .select()
          .order('id')
          .limit(6);

      setState(() {
        countries = countryData;
        universities = universityData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0,
        title: const Text('EduGuide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const Drawer(child: DashboardDrawer()),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Welcome
                    const Text(
                      "Welcome back 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search universities...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Featured Countries
                    sectionTitle("Featured Countries"),
                    const SizedBox(height: 15),

                    SizedBox(
                      height: 160,
                      child: countries.isEmpty
                          ? const Center(child: Text("No countries available"))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: countries.length,
                              itemBuilder: (context, index) {
                                final country = countries[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/country',
                                      arguments: country,
                                    );
                                  },
                                  child: Container(
                                    width: 140,
                                    margin:
                                        const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          country['image_url'] ??
                                              'https://via.placeholder.com/150',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      alignment: Alignment.bottomLeft,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Text(
                                        country['name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 30),

                    /// Popular Universities
                    sectionTitle("Popular Universities"),
                    const SizedBox(height: 15),

                    universities.isEmpty
                        ? const Center(
                            child: Text("No universities available"))
                        : Column(
                            children: universities
                                .map((uni) => universityCard(uni))
                                .toList(),
                          ),

                    const SizedBox(height: 30),

                    /// Quick Actions
                    sectionTitle("Quick Actions"),
                    const SizedBox(height: 15),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        quickAction(Icons.book, "IELTS Prep", '/ielts'),
                        quickAction(Icons.school, "Scholarships",
                            '/scholarships'),
                        quickAction(Icons.flight, "Visa Guidance", '/visa'),
                        quickAction(Icons.track_changes,
                            "Application Tracker", '/tracker'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget universityCard(dynamic uni) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              uni['logo_url'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.school,
                    color: Colors.blue, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  uni['name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  uni['location'] ?? '',
                  style:
                      const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "From ${uni['tuition_fee'] ?? 'N/A'}/year",
                  style: const TextStyle(
                      color: Colors.orange),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/universityDetails',
                arguments: uni,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30),
              ),
            ),
            child: const Text("View"),
          )
        ],
      ),
    );
  }

  Widget quickAction(
      IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}