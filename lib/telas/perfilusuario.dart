import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:http/http.dart' as http;

// ─── Modelo de Usuário ────────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Usuário Desconhecido',
      email: json['email'] ?? 'email@exemplo.com',
      avatarUrl: json['avatarUrl'] ?? '',
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
      await Future.delayed(const Duration(seconds: 2));
      final Map<String, dynamic> apiResponse = {
        'name': 'Maria Eduarda',
        'email': 'maria.eduarda@email.com',
        'avatarUrl': '',
      };

      setState(() {
        _userProfile = UserProfile.fromJson(apiResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar perfil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // ── HEADER COM SETA DE VOLTAR ────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 30), // Ajustado para a seta
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: CoresGlobais.backgrounder,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // 🔹 LINHA DA SETA
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context), // Volta para a tela anterior
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
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white24,
                                backgroundImage: _userProfile!.avatarUrl.isNotEmpty
                                    ? NetworkImage(_userProfile!.avatarUrl)
                                    : null,
                                child: _userProfile!.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 45, color: Colors.white)
                                    : null,
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
          // 🔹 CARDS DE OPÇÕES
          _itemPerfil(Icons.settings, "Configurações"),
          _itemPerfil(Icons.security, "Segurança"),
          _itemPerfil(Icons.notifications, "Notificações"),
          _itemPerfil(Icons.logout, "Sair", isLogout: true),
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

  Widget _itemPerfil(IconData icon, String text, {bool isLogout = false}) {
    return Container(
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
          Icon(
            icon,
            color: isLogout ? Colors.red : Colors.black,
          ),
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
    );
  }
}
