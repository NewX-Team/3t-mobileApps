import 'package:flutter/material.dart';
import 'package:layanan_masyarakat3t/features/home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  /// Interactive controller: 0.0 = Login Mode, 1.0 = Register Mode.
  late final AnimationController _slideController;

  /// Micro-bobbing controller for the pull handle chevron to invite user interaction.
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  // Login form controllers & state
  final _loginIdController = TextEditingController();
  final _loginPinController = TextEditingController();
  bool _loginObscurePin = true;
  bool _rememberMe = true;
  int _userTypeIndex = 0; // 0 = Warga 3T, 1 = Petugas / Aparatur Desa

  // Register form controllers & state
  final _regNameController = TextEditingController();
  final _regNikController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPinController = TextEditingController();
  bool _regObscurePin = true;
  int _selectedRegionIndex = 0;

  final List<String> _regionBadges = [
    'Pulau Terluar',
    'Perbatasan Darat',
    'Pesisir Terisolir',
    'Pedalaman 3T',
  ];

  // Travel distance in pixels for the physical drag transition
  static const double _travelDistance = 460.0;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -2.5, end: 3.5).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _loginIdController.dispose();
    _loginPinController.dispose();
    _regNameController.dispose();
    _regNikController.dispose();
    _regPhoneController.dispose();
    _regPinController.dispose();
    super.dispose();
  }

  void _switchToRegister() {
    FocusScope.of(context).unfocus();
    _slideController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _switchToLogin() {
    FocusScope.of(context).unfocus();
    _slideController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _submitAuth() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const HomeScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // --- Real-Time 1:1 Touch Drag Handling ---
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    // Direct pixel-for-pixel responsive calculation (no floatiness)
    final progressDelta = delta / _travelDistance;
    _slideController.value =
        (_slideController.value + progressDelta).clamp(0.0, 1.0);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 320) {
      // Fast downward swipe -> Snap to Register
      _slideController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else if (velocity < -320) {
      // Fast upward swipe -> Snap to Login
      _slideController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Snap to whichever side is closer (threshold 40%)
      if (_slideController.value >= 0.40) {
        _slideController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      } else {
        _slideController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const canvasBackground = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: canvasBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 1. Sleek Top Navigation Bar & Interactive Mode Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _buildTopBar(),
              ),
              const SizedBox(height: 14),

              // 2. Interactive Sliding Dual Card Area
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    final progress = _slideController.value;

                    // Physical vertical translation offsets:
                    // Login Card moves from 0 to +_travelDistance (pulled down)
                    final loginOffsetY = progress * _travelDistance;
                    final loginOpacity = (1.0 - progress * 1.3).clamp(0.0, 1.0);

                    // Register Card moves from -_travelDistance to 0 (descends from top)
                    final registerOffsetY = -(1.0 - progress) * _travelDistance;
                    final registerOpacity =
                        ((progress - 0.15) / 0.85).clamp(0.0, 1.0);

                    return Stack(
                      children: [
                        // LOGIN PANEL
                        if (loginOpacity > 0.001)
                          Transform.translate(
                            offset: Offset(0, loginOffsetY),
                            child: Opacity(
                              opacity: loginOpacity,
                              child: _buildLoginPanel(),
                            ),
                          ),

                        // REGISTER PANEL
                        if (registerOpacity > 0.001)
                          Transform.translate(
                            offset: Offset(0, registerOffsetY),
                            child: Opacity(
                              opacity: registerOpacity,
                              child: _buildRegisterPanel(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR & SEGMENTED SWITCHER
  // ===========================================================================
  Widget _buildTopBar() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final isRegister = _slideController.value >= 0.5;

        return Column(
          children: [
            // Branding header
            Row(
              children: [
                // Solid Mini G Emblem
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'LAYANAN MASYARAKAT 3T',
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Portal Autentikasi Mandiri & Terpadu',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Emergency Guest Shortcut
                InkWell(
                  onTap: _submitAuth,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.emergency_outlined,
                          size: 13,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Akses Tamu',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Interactive Segmented Pill Switcher
            Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 1.0,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = (constraints.maxWidth - 4) / 2;
                  final pillOffset = _slideController.value * tabWidth;

                  return Stack(
                    children: [
                      // Active indicator pill
                      Positioned(
                        left: pillOffset,
                        top: 0,
                        bottom: 0,
                        width: tabWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                      // Tab Options
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _switchToLogin,
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  'Masuk Akun',
                                  style: TextStyle(
                                    color: isRegister
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF0F172A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _switchToRegister,
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  'Registrasi Warga',
                                  style: TextStyle(
                                    color: isRegister
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // LOGIN PANEL
  // ===========================================================================
  Widget _buildLoginPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        children: [
          // Scrollable login inputs
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  const Text(
                    'Masuk ke Layanan',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Autentikasi warga daerah terdepan, terluar, tertinggal',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User type selection pill
                  Container(
                    height: 36,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildUserTypeChip('Warga 3T', 0),
                        _buildUserTypeChip('Petugas / Staf Desa', 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Field 1: NIK / WhatsApp
                  _buildInputLabel(
                    _userTypeIndex == 0
                        ? 'Nomor Induk Kependudukan (NIK)'
                        : 'ID Pegawai / NIK Petugas',
                  ),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _loginIdController,
                    hint: _userTypeIndex == 0
                        ? '16 Digit NIK KTP'
                        : 'Masukkan ID Petugas',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Field 2: PIN Keamanan
                  _buildInputLabel('PIN Keamanan (6 Digit)'),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _loginPinController,
                    hint: '6 Digit angka PIN akun',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    obscureText: _loginObscurePin,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _loginObscurePin
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        setState(() => _loginObscurePin = !_loginObscurePin);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remember me checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Simpan sesi login di perangkat ini',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: const Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Masuk Sekarang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- TACTILE PULL-DOWN RIBBON TO REGISTER ---
          InkWell(
            onTap: _switchToRegister,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(18)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(17)),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator handle pill
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'TARIK KE BAWAH UNTUK DAFTAR WARGA BARU',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Geser layar ke bawah atau ketuk pita ini',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REGISTER PANEL
  // ===========================================================================
  Widget _buildRegisterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        children: [
          // --- TACTILE PULL-UP RIBBON TO LOGIN ---
          InkWell(
            onTap: _switchToLogin,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TARIK KE ATAS UNTUK KEMBALI KE LOGIN',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Geser layar ke atas atau ketuk pita ini',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Drag indicator handle pill
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable registration inputs
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pendaftaran Warga Baru',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Registrasi identitas untuk akses administrasi & bantuan desa',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field 1: Nama Lengkap
                  _buildInputLabel('Nama Lengkap (Sesuai KTP)'),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _regNameController,
                    hint: 'Contoh: Ahmad Hidayat',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 12),

                  // Field 2: NIK 16 Digit
                  _buildInputLabel('Nomor Induk Kependudukan (16 Digit NIK)'),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _regNikController,
                    hint: '16 Digit angka pada KTP / KK',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Field 3: WhatsApp
                  _buildInputLabel('Nomor WhatsApp / HP Aktif'),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _regPhoneController,
                    hint: '0812xxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // Field 4: Wilayah 3T Chip Selector
                  _buildInputLabel('Kategori Wilayah Domisili 3T'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_regionBadges.length, (index) {
                      final isSelected = _selectedRegionIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedRegionIndex = index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFCBD5E1),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            _regionBadges[index],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Field 5: PIN Akses
                  _buildInputLabel('Buat PIN Akses Baru (6 Digit)'),
                  const SizedBox(height: 6),
                  _buildTextInput(
                    controller: _regPinController,
                    hint: '6 Digit angka PIN rahasia',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    obscureText: _regObscurePin,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _regObscurePin
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        setState(() => _regObscurePin = !_regObscurePin);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: const Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Selesaikan Pendaftaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REUSABLE FORM WIDGETS
  // ===========================================================================
  Widget _buildUserTypeChip(String label, int index) {
    final isSelected = _userTypeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userTypeIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: const Color(0xFFCBD5E1), width: 1.0)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, size: 19, color: const Color(0xFF64748B)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
        ),
      ),
    );
  }
}
