🎶 Harmoniq: Tu Estudio Musical Personal con IA 🎶

¡Bienvenido a Harmoniq! Una aplicación móvil innovadora que te permite crear y editar música con un intuitivo editor MIDI, potenciado por capacidades de inteligencia artificial que te ayudarán a componer y transformar tus melodías. Ya seas un músico experimentado o un principiante curioso, Harmoniq está aquí para impulsar tu creatividad.
✨ Características Destacadas

    Editor MIDI Visual: Crea y edita notas musicales de forma intuitiva en una interfaz de piano roll.

    Asistencia de IA (Gemini):

        Añadir Capas: Pide a la IA que genere líneas de bajo, armonías o contramelodías para complementar tu música existente.

        Reemplazar Melodías: Genera melodías completamente nuevas basándose en tus descripciones.

        Transformar Melodías: Modifica tus melodías existentes (ej. transponer, cambiar el estado de ánimo, variar el ritmo) con simples comandos.

        Chat General: Conversa con la IA para obtener ideas, consejos musicales o simplemente explorar posibilidades.

    Reproducción Integrada: Escucha tus composiciones directamente dentro de la aplicación.

    Gestión de Proyectos: Guarda, abre y elimina tus proyectos musicales.

    Autenticación de Usuario: Inicia sesión con correo/contraseña o Google para guardar tus proyectos de forma segura.

    Perfil de Usuario: Gestiona la información de tu perfil.

    Diseño Moderno y Adaptable: Una interfaz limpia y atractiva, optimizada para diferentes dispositivos.

🛠️ Tecnologías Utilizadas

    Flutter: Framework de desarrollo de UI para construir aplicaciones compiladas de forma nativa para móvil, web y escritorio desde una única base de código.

    Firebase:

        Firebase Authentication: Para la gestión de usuarios (correo/contraseña, Google Sign-In, anónimo).

        Cloud Firestore: Base de datos NoSQL para almacenar los proyectos musicales y perfiles de usuario.

    Google Gemini API: El modelo de lenguaje grande (LLM) de Google para las funciones de generación musical y chat.

    flutter_midi: Para la reproducción de audio MIDI.

    linked_scroll_controller: Para la sincronización de scroll en el editor MIDI.

    uuid: Para la generación de IDs únicos.

    http: Para realizar llamadas a la API de Gemini.


💡 Uso de la Aplicación

    Inicio de Sesión/Registro: Al abrir la aplicación, puedes registrarte con tu correo y contraseña, o usar el inicio de sesión con Google. También puedes iniciar sesión de forma anónima si estás usando el entorno de Canvas.

    Página Principal: Verás tus proyectos. Puedes crear uno nuevo tocando el botón +.

    Crear Proyecto: Dale un nombre a tu proyecto y ábrelo en el editor.

    Editor MIDI:

        Toca en la cuadrícula para añadir notas.

        Haz doble toque en una nota para eliminarla.

        Mantén pulsado una nota para abrir opciones (mover, redimensionar).

        Usa el deslizador de zoom para ajustar la vista del editor.

        Usa el botón de Play/Stop para reproducir tu composición.

    Pestaña de IA:

        Usa los botones de acción (Añadir Línea de Bajo, Reemplazar Melodía, Transformar Melodía) para interactuar con la IA y generar o modificar notas.

        Escribe en el campo de texto y presiona enviar para un Chat General con la IA.

    Pestaña de Ajustes: Aquí podrás modificar los ajustes de tu proyecto (tempo, género, etc.).

    Perfil de Usuario: Toca tu avatar en la página principal para ver y editar tu perfil (nombre de usuario, correo electrónico).
