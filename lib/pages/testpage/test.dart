import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Row(
          children: [
            _buildTab('新标签页', 0),
            _buildTab('+', 1, isAddButton: true),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Center(child: Text('内容1')),
          Center(child: Text('添加新标签')),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index, {bool isAddButton = false}) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: CustomPaint(
        painter: TabPainter(isSelected: _currentIndex == index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              if (!isAddButton) Icon(Icons.chrome_reader_mode, size: 16.0),
              SizedBox(width: 4.0),
              Text(text, style: TextStyle(color: Colors.white)),
              if (!isAddButton) ...[
                SizedBox(width: 4.0),
                Icon(Icons.close, size: 16.0, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TabPainter extends CustomPainter {
  final bool isSelected;

  TabPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isSelected ? Colors.grey[700] : Colors.grey[600])!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.1, 0, size.width * 0.1, 0);
    path.lineTo(size.width * 0.8, 0);
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          width: 70,
          height: 40,
          decoration: BoxDecoration(
            // color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Inner shadow container to simulate the inset shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Darker shadow on top-left for the inset effect
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: Offset(-3, -3),
                      blurRadius: 5,
                    ),
                    // Lighter shadow on bottom-right for the inset effect
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.7),
                      offset: Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 400),
                left: isChecked ? 35 : 5,
                top: 5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ],
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

class ResizableContainer extends StatefulWidget {
  const ResizableContainer({super.key});

  @override
  _ResizableContainerState createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  double _width = 200;
  double _height = 200;

  void _updateSize(DragUpdateDetails details, String position) {
    setState(() {
      switch (position) {
        case 'top':
          _height -= details.delta.dy;
          break;
        case 'bottom':
          _height += details.delta.dy;
          break;
        case 'left':
          _width -= details.delta.dx;
          break;
        case 'right':
          _width += details.delta.dx;
          break;
        case 'topLeft':
          _width -= details.delta.dx;
          _height -= details.delta.dy;
          break;
        case 'topRight':
          _width += details.delta.dx;
          _height -= details.delta.dy;
          break;
        case 'bottomLeft':
          _width -= details.delta.dx;
          _height += details.delta.dy;
          break;
        case 'bottomRight':
          _width += details.delta.dx;
          _height += details.delta.dy;
          break;
      }

      // 限制最小尺寸，防止变为负数或太小
      _width = _width.clamp(50.0, double.infinity);
      _height = _height.clamp(50.0, double.infinity);
    });
  }

  Widget _buildDragHandle(String position, Alignment alignment) {
    return Positioned(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onPanUpdate: (details) => _updateSize(details, position),
          child: Container(
            width: 20,
            height: 20,
            color: Colors.blue.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
            width: _width,
            height: _height,
            color: Colors.blueAccent,
          ),
          // 边的拖动控件
          Positioned(
            // left: _width / 2 - 10,
            top: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'top'),
              child: Container(width: _width, height: 20, color: Colors.purple),
            ),
          ),
          Positioned(
            // left: _width / 2 - 10,
            bottom: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'bottom'),
              child: Container(width: _width, height: 20, color: Colors.purple),
            ),
          ),
          Positioned(
            left: -10,
            // top: _height / 2 - 10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'left'),
              child:
                  Container(width: 20, height: _height, color: Colors.purple),
            ),
          ),
          Positioned(
            right: -10,
            // top: _height / 2 - 10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'right'),
              child:
                  Container(width: 20, height: _height, color: Colors.purple),
            ),
          ),
          // 角落的拖动控件
          Positioned(
            left: -10,
            top: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'topLeft'),
              child: Container(width: 20, height: 20, color: Colors.red),
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'topRight'),
              child: Container(width: 20, height: 20, color: Colors.green),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'bottomLeft'),
              child: Container(width: 20, height: 20, color: Colors.yellow),
            ),
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: GestureDetector(
              onPanUpdate: (details) => _updateSize(details, 'bottomRight'),
              child: Container(width: 20, height: 20, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
