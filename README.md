# Snake 🐍

Clásico juego **Snake (La Serpiente)** recreado en **Flutter** para Android, inspirado en el icónico Snake de Nokia (1997–1998), con una interfaz moderna, pantalla completa y controles por deslizamiento.

## ✨ Características

- 🎮 Gameplay clásico de Snake
- 📱 Pantalla completa (immersive mode)
- 📐 Tablero responsivo que se adapta al tamaño del dispositivo
- 👆 Controles por gesto (swipe)
- 🔊 Sonido con efectos (comer y game over)
- 🏆 Puntaje máximo persistente
- 🎨 Estilo visual limpio y minimalista
- 🤖 Optimizado para dispositivos modernos (ej. Pixel 8)

## 🛠️ Tecnologías usadas

- **Flutter**
- **Dart**
- **Riverpod** (gestión de estado)
- **CustomPainter** (render del tablero)
- **Shared Preferences** (persistencia)
- **audioplayers** (sonido)

## 📂 Estructura del proyecto

```text
lib/
 ├── game/
 │   ├── game_notifier.dart
 │   ├── game_state.dart
 │   ├── preferences.dart
 │   └── sound_service.dart
 ├── ui/
 │   └── game_screen.dart
 └── main.dart

assets/
 ├── sfx/
 │   ├── eat.wav
 │   └── game_over.wav
 └── icon/
     └── icon.png
▶️ Cómo ejecutar el proyecto
Clona el repositorio:

bash
Copiar código
git clone https://github.com/tu-usuario/snake.git
cd snake
Instala dependencias:

bash
Copiar código
flutter pub get
Ejecuta en un dispositivo o emulador Android:

bash
Copiar código
flutter run
🖼️ Ícono de la app
El proyecto usa un ícono personalizado inspirado en Snake Nokia.
Para regenerarlo:

bash
Copiar código
dart run flutter_launcher_icons
🎯 Controles
Desliza el dedo en la pantalla para cambiar la dirección.

El juego termina al chocar con el borde o con el cuerpo.

En Game Over puedes:

Reiniciar la partida

Activar / desactivar sonido

📌 Notas
No hay botones visibles durante el juego (UI limpia).

Toda la información se muestra solo al finalizar la partida.

El tamaño del tablero se ajusta automáticamente al dispositivo.

📄 Licencia
Proyecto de uso educativo y personal.
Inspirado en el clásico Snake de Nokia.

