import 'package:flutter/material.dart';
import 'package:layanan_masyarakat3t/features/auth/auth_screen.dart';
import 'package:layanan_masyarakat3t/features/splash/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Solid color palette: Slate, White, and Civic Emerald / Navy
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryColor = Color(0xFF0F172A);
    const accentColor = Color(0xFF0D9488);
    const cardBorderColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'LAYANAN MASYARAKAT 3T',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kecamatan Pulau Terluar • Terkoneksi Lokal',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Quick button to replay the splash animation
          IconButton(
            tooltip: 'Putar Ulang Splash',
            icon: const Icon(
              Icons.replay,
              color: Color(0xFFE2E8F0),
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Halaman Masuk / Registrasi',
            icon: const Icon(
              Icons.person_outline,
              color: Color(0xFFE2E8F0),
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. Offline Mode Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cardBorderColor, width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.cloud_done_outlined,
                    color: Color(0xFF0F172A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Penyimpanan Lokal Aktif',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Laporan & permohonan dapat diisi tanpa sinyal dan tersinkron otomatis saat terhubung.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Header
          const Text(
            'Layanan Utama',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // 2. Service Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _buildServiceCard(
                icon: Icons.description_outlined,
                title: 'Surat Desa',
                subtitle: 'Domisili, Usaha, KTP',
                badgeText: 'Offline Ready',
              ),
              _buildServiceCard(
                icon: Icons.campaign_outlined,
                title: 'Lapor Warga',
                subtitle: 'Jalan, Listrik, Air',
                badgeText: 'Foto & GPS',
              ),
              _buildServiceCard(
                icon: Icons.inventory_2_outlined,
                title: 'Bantuan Sosial',
                subtitle: 'Jadwal Logistik & BLT',
                badgeText: 'Penerima',
              ),
              _buildServiceCard(
                icon: Icons.emergency_outlined,
                title: 'Pos Darurat',
                subtitle: 'Puskesmas & Bidan',
                badgeText: 'Panggilan SOS',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Recent Pending Sync / Activity Section
          const Text(
            'Antrean Laporan & Sinkronisasi',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cardBorderColor, width: 1.0),
            ),
            child: Column(
              children: [
                _buildActivityTile(
                  title: 'Laporan Kerusakan Dermaga Dusun 2',
                  date: 'Hari ini • 14:20 WITA',
                  status: 'Tersimpan di HP (Antrean Kirim)',
                  statusColor: const Color(0xFFD97706),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildActivityTile(
                  title: 'Permohonan Surat Keterangan Usaha',
                  date: 'Kemarin • 09:15 WITA',
                  status: 'Terkirim ke Kantor Desa',
                  statusColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Pengaduan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Permohonan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withAlpha(80), width: 1.0),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
