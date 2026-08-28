import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/auth/login.dart';
import 'package:meu_apli/telas/notificacoes_screen.dart';
import 'package:meu_apli/telas/configura%C3%A7ao/alterar_senha_screen.dart';
import 'package:meu_apli/telas/configuraçao/configuracao_screen.dart';

const List<String> kAvataresDisponiveis = [
  'avatar_1', 'avatar_2', 'avatar_3', 'avatar_4',
  'avatar_5', 'avatar_6', 'avatar_7', 'avatar_8',
];

String avatarAssetPath(String avatar) => 'assets/avatars/$avatar.png';

// ─── Modelo de Usuário ────────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final String email;
  final String avatar;

  const UserProfile({
    required this.name,
    required this.email,
    this.avatar = 'avatar_1',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Usuário',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? 'avatar_1',
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  bool _atualizandoAvatar = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.buscarPerfil();
      setState(() {
        _userProfile = UserProfile.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar perfil: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _abrirSeletorDeAvatar() async {
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha seu avatar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: kAvataresDisponiveis.map((avatar) {
                  final selecionado = avatar == _userProfile?.avatar;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, avatar),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: selecionado
                          ? const Color(0xFF6A5AE0)
                          : Colors.grey[200],
                      child: CircleAvatar(
                        radius: 29,
                        backgroundImage: AssetImage(avatarAssetPath(avatar)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (escolhido == null || escolhido == _userProfile?.avatar) return;

    setState(() => _atualizandoAvatar = true);
    try {
      await ApiService.atualizarAvatar(escolhido);
      setState(() {
        _userProfile = UserProfile(
          name: _userProfile!.name,
          email: _userProfile!.email,
          avatar: escolhido,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar avatar')),
        );
      }
    } finally {
      if (mounted) setState(() => _atualizandoAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: CoresGlobais.backgrounder),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error != null
                        ? _buildErrorWidget()
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: _atualizandoAvatar ? null : _abrirSeletorDeAvatar,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: AssetImage(
                                        avatarAssetPath(_userProfile!.avatar),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, size: 16, color: Color(0xFF6A5AE0)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _userProfile!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _userProfile!.email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
              ],
            ),
          ),

          const SizedBox(height: 20),
         _itemPerfil(Icons.settings, "Configurações", onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfiguracoesScreen(
              nomeAtual: _userProfile!.name,
              emailAtual: _userProfile!.email,
      ),
    ),
  );
}),
          _itemPerfil(
  Icons.notifications,
  "Notificações",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificacoesScreen(),
      ),
    );
  },
),
          _itemPerfil(Icons.logout, "Sair", isLogout: true, onTap: _logout),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchUserProfile,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _itemPerfil(
    IconData icon,
    String text, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.black),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}