import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para User, updateDisplayName, updateEmail
import 'package:cloud_firestore/cloud_firestore.dart'; // Para guardar en Firestore
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para localización

class UserProfileEditPage extends StatefulWidget {
  final User user; // El usuario actual
  final bool isGoogleUser; // Indica si el usuario es de Google

  const UserProfileEditPage({
    super.key,
    required this.user,
    required this.isGoogleUser,
  });

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  // Controladores para los campos de texto
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController; // Para una descripción adicional

  bool _isLoading = false; // Estado de carga para el botón de guardar

  // Instancias directas de FirebaseAuth y FirebaseFirestore
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los datos actuales del usuario
    _displayNameController = TextEditingController(text: widget.user.displayName ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _descriptionController = TextEditingController(); // Puede cargarse desde Firestore

    // Inicializar las instancias de Firebase directamente
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    // Cargar datos adicionales del perfil (como la descripción) desde Firestore
    _loadUserProfileData();
  }

  // Carga datos adicionales del perfil desde Firestore
  Future<void> _loadUserProfileData() async {
    final userId = _auth.currentUser?.uid; // Obtener userId directamente de FirebaseAuth
    if (userId == null) {
      print("Error: No hay userId disponible para cargar el perfil.");
      return;
    }

    try {
      final docSnapshot = await _firestore // Usar la instancia directa de Firestore
          .collection('artifacts')
          .doc('harmoniq-app') // Reemplaza con tu app_id si es dinámico en otros lugares
          .collection('users')
          .doc(userId)
          .collection('userProfiles')
          .doc('profile')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('description')) {
          setState(() {
            _descriptionController.text = data['description'] as String;
          });
        }
      }
    } catch (e) {
      print("Error al cargar datos del perfil de usuario: $e");
    }
  }


  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Muestra un Snackbar con un mensaje
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // Maneja el guardado de los cambios del perfil
  Future<void> _saveProfileChanges() async {
    setState(() {
      _isLoading = true;
    });

    final localizations = AppLocalizations.of(context)!;
    User? currentUser = _auth.currentUser; // Obtener usuario actual directamente

    if (currentUser == null) {
      _showSnackbar(localizations.notAuthenticated, isError: true);
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Actualizar displayName si es diferente
      if (currentUser.displayName != _displayNameController.text) {
        await currentUser.updateDisplayName(_displayNameController.text);
      }

      // Actualizar email si no es usuario de Google y es diferente
      if (!widget.isGoogleUser && currentUser.email != _emailController.text) {
        await currentUser.updateEmail(_emailController.text);
      }

      // Guardar datos adicionales en Firestore
      final userId = currentUser.uid; // Usar uid directamente del currentUser
      if (userId != null) {
        await _firestore // Usar la instancia directa de Firestore
            .collection('artifacts')
            .doc('harmoniq-app') // Usar un ID de aplicación fijo o dinámico
            .collection('users')
            .doc(userId)
            .collection('userProfiles')
            .doc('profile') // Un documento fijo para el perfil de cada usuario
            .set({
              'description': _descriptionController.text,
              // Puedes guardar otros campos aquí si los añades
            }, SetOptions(merge: true)); // Usar merge para no sobrescribir todo el documento
      }

      // Recargar el usuario para que los cambios se reflejen inmediatamente en la UI
      await currentUser.reload();
      setState(() {
        // Forzar reconstrucción para que el widget.user en _UserProfileScreen
        // muestre los datos actualizados después de la navegación de vuelta.
        // Esto no es estrictamente necesario aquí si UserProfileScreen escucha authStateChanges,
        // pero es una buena práctica para asegurar la consistencia.
      });

      _showSnackbar(localizations.profileSavedSuccess);
      if (mounted) Navigator.of(context).pop(); // Volver a la pantalla anterior
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? localizations.profileSaveError, isError: true);
    } catch (e) {
      _showSnackbar(localizations.profileSaveErrorGeneric(e.toString()), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Determinar si los campos de edición de correo y nombre son editables
    final bool canEditEmailAndDisplayName = !widget.isGoogleUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.editProfileTitle),
        actions: [
          // Solo mostrar el botón de guardar si no es usuario de Google
          if (!widget.isGoogleUser) 
            IconButton(
              icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfileChanges,
              tooltip: localizations.saveSettings,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de Nombre de Usuario (displayName)
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: localizations.usernamePlaceholder,
                  border: const OutlineInputBorder(),
                  enabled: canEditEmailAndDisplayName, // Solo editable si no es Google
                ),
                readOnly: !canEditEmailAndDisplayName, // Solo de lectura si es Google
                style: TextStyle(
                  color: canEditEmailAndDisplayName ? null : Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Correo Electrónico (email)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: localizations.emailPlaceholder,
                  border: const OutlineInputBorder(),
                  enabled: canEditEmailAndDisplayName, // Solo editable si no es Google
                ),
                readOnly: !canEditEmailAndDisplayName, // Solo de lectura si es Google
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: canEditEmailAndDisplayName ? null : Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 20),

              // Mensaje para usuarios de Google
              if (widget.isGoogleUser)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    localizations.googleUserEditWarning,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Botón de guardar (se oculta en el AppBar si el usuario no es de Google, para evitar duplicidad)
              if (!widget.isGoogleUser)
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfileChanges,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(localizations.saveSettings),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
