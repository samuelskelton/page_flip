import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _controller = GlobalKey<PageFlipWidgetState>();

  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  TapDownDetails? _tapDownDetails;
  Animation<Matrix4>? _animation;
  final zoomMaxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        _transformationController.value = _animation!.value;
      });
  }

  void _zoomOnDoubleTap() {
    final currentPosition = _tapDownDetails!.localPosition;
    final xPos = -currentPosition.dx;
    final yPos = -currentPosition.dy;

    final zoomed = Matrix4.identity()
      ..translate(xPos, yPos)
      ..scale(zoomMaxScale / 2);
    final zoomedStateValue =
        (_transformationController.value.getMaxScaleOnAxis() <
                (zoomMaxScale / 2))
            ? zoomed
            : Matrix4.identity();
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: zoomedStateValue,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Page ${currentPageIndex.value + 1}",
            style: const TextStyle(color: Colors.black, fontSize: 34),
          ),
          Container(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 0.75,
              child: PageFlipWidget(
                  key: _controller,
                  onDoubleTapDown: (details) => _tapDownDetails = details,
                  maxScale: zoomMaxScale,
                  clipBehavior: Clip.none,
                  transformationController: _transformationController,
                  onDoubleTapPage: _zoomOnDoubleTap,
                  onTapPage: () {},
                  backgroundColor: Colors.transparent,
                  currentPage: (int index) {
                    _resetZoom();
                  },
                  children: <Widget>[
                    for (var i = 0; i < 10; i++)
                      Image.network('https://picsum.photos/45$i'),
                  ]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () => _controller.currentState?.turnPagePrevious(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                "${currentPageIndex.value + 1} of 10",
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () => _controller.currentState?.turnPageForward(),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.looks_5_outlined),
        onPressed: () {
          _controller.currentState?.goToPage(4);
          setState(() {});
        },
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
