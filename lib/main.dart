import 'package:flutter/material.dart';

void main() {
  runApp(const Six7Game());
}

class Six7Game extends StatelessWidget {
  const Six7Game({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '67',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF00),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const int gridSize = 20;
  static const double cellSize = 18.0;

  late List<Offset> snake;
  Offset food = Offset.zero;
  Offset direction = const Offset(1, 0);
  int score = 0;
  int highScore = 0;
  bool isPlaying = false;
  bool isGameOver = false;
  late Ticker _ticker;
  double _tickAccumulator = 0.0;
  static const double tickInterval = 120.0; // ms per move

  @override
  void initState() {
    super.initState();
    _initGame();
    _ticker = createTicker(_onTick)..start();
  }

  void _initGame() {
    snake = [
      const Offset(gridSize / 2, gridSize / 2),
      const Offset(gridSize / 2 - 1, gridSize / 2),
      const Offset(gridSize / 2 - 2, gridSize / 2),
    ];
    direction = const Offset(1, 0);
    score = 0;
    isPlaying = false;
    isGameOver = false;
    _spawnFood();
  }

  void _spawnFood() {
    final random = DateTime.now().millisecondsSinceEpoch;
    do {
      food = Offset(
        (random + snake.length * 7) % gridSize,
        (random * 13 + snake.length * 11) % gridSize,
      ).floorToOffset();
    } while (snake.any((s) => s == food));
  }

  void _onTick(Duration elapsed) {
    if (!isPlaying || isGameOver) return;

    _tickAccumulator += elapsed.inMilliseconds.toDouble();
    if (_tickAccumulator < tickInterval) return;
    _tickAccumulator = 0;

    final head = snake.first + direction;
    final newHead = Offset(
      (head.dx % gridSize + gridSize) % gridSize,
      (head.dy % gridSize + gridSize) % gridSize,
    );

    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      score += 10;
      _spawnFood();
    } else {
      snake.removeLast();
    }

    setState(() {});
  }

  void _gameOver() {
    isGameOver = true;
    isPlaying = false;
    highScore = highScore > score ? highScore : score;
    setState(() {});
  }

  void _startGame() {
    if (isGameOver) {
      _initGame();
    }
    isPlaying = true;
    setState(() {});
  }

  void _changeDirection(Offset newDir) {
    if (!isPlaying && !isGameOver) {
      _startGame();
    }
    if (direction + newDir != Offset.zero) {
      direction = newDir;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = gridSize * cellSize;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '67',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF00),
                      letterSpacing: 4,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SCORE: $score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'HIGH: $highScore',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B949E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Game Board
            Expanded(
              child: Center(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0) {
                      _changeDirection(const Offset(0, 1));
                    } else if (details.delta.dy < 0) {
                      _changeDirection(const Offset(0, -1));
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0) {
                      _changeDirection(const Offset(1, 0));
                    } else if (details.delta.dx < 0) {
                      _changeDirection(const Offset(-1, 0));
                    }
                  },
                  child: Container(
                    width: boardSize,
                    height: boardSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF30363D), width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF00).withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _GamePainter(
                        snake: snake,
                        food: food,
                        cellSize: cellSize,
                        gridSize: gridSize,
                        isGameOver: isGameOver,
                      ),
                      size: Size(boardSize, boardSize),
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Up button
                  _ControlButton(
                    icon: Icons.keyboard_arrow_up,
                    onTap: () => _changeDirection(const Offset(0, -1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left button
                      _ControlButton(
                        icon: Icons.keyboard_arrow_left,
                        onTap: () => _changeDirection(const Offset(-1, 0)),
                      ),
                      const SizedBox(width: 60),
                      // Right button
                      _ControlButton(
                        icon: Icons.keyboard_arrow_right,
                        onTap: () => _changeDirection(const Offset(1, 0)),
                      ),
                    ],
                  ),
                  // Down button
                  _ControlButton(
                    icon: Icons.keyboard_arrow_down,
                    onTap: () => _changeDirection(const Offset(0, 1)),
                  ),
                ],
              ),
            ),

            // Overlay messages
            if (!isPlaying && !isGameOver)
              _buildOverlay('TAP TO START', 'Swipe or use buttons to move'),
            if (isGameOver)
              _buildOverlay('GAME OVER', 'Tap to restart'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(String title, String subtitle) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xCC0D1117),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FF00),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B949E),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  foregroundColor: const Color(0xFF0D1117),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isGameOver ? 'RESTART' : 'START',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final double cellSize;
  final int gridSize;
  final bool isGameOver;

  _GamePainter({
    required this.snake,
    required this.food,
    required this.cellSize,
    required this.gridSize,
    required this.isGameOver,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Grid background
    paint.color = const Color(0xFF161B22);
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if ((x + y) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    // Food
    final foodPaint = Paint()
      ..color = const Color(0xFFFF3366)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(food.dx * cellSize + cellSize / 2, food.dy * cellSize + cellSize / 2),
      cellSize * 0.35,
      foodPaint,
    );

    // Snake
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          segment.dx * cellSize + 1,
          segment.dy * cellSize + 1,
          cellSize - 2,
          cellSize - 2,
        ),
        Radius.circular(cellSize * 0.2),
      );

      final gradient = LinearGradient(
        colors: [
          const Color(0xFF00FF00),
          const Color(0xFF00CC00),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      paint
        ..shader = gradient.createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      // Eyes on head
      if (i == 0 && !isGameOver) {
        final eyePaint = Paint()..color = const Color(0xFF0D1117);
        final eyeOffset = cellSize * 0.25;
        final centerX = segment.dx * cellSize + cellSize / 2;
        final centerY = segment.dy * cellSize + cellSize / 2;

        canvas.drawCircle(
          Offset(centerX - eyeOffset, centerY - eyeOffset),
          cellSize * 0.08,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(centerX + eyeOffset, centerY - eyeOffset),
          cellSize * 0.08,
          eyePaint,
        );
      }
    }

    // Game over overlay on board
    if (isGameOver) {
      final overlayPaint = Paint()..color = const Color(0xCC000000);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF00).withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00FF00),
          size: 28,
        ),
      ),
    );
  }
}

extension OffsetExt on Offset {
  Offset operator +(Offset other) => Offset(dx + other.dx, dy + other.dy);
  Offset floorToOffset() => Offset(dx.floorToDouble(), dy.floorToDouble());
}