import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GridContent extends StatelessWidget {
  const GridContent({
    super.key,
    required this.gridIcon,
    required this.gridLabel,
    this.onTap,
  });

  final List<Widget> gridIcon;
  final List<String> gridLabel;
  final Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        Widget gridItem = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              gridIcon[index],
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  gridLabel[index],
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 11,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        );

        if (onTap != null) {
          return InkWell(
            onTap: () => onTap!(index),
            borderRadius: BorderRadius.circular(10),
            child: gridItem,
          );
        }

        return gridItem;
      },
    );
  }
}

class GridIcons extends StatelessWidget {
  final IconData icon;
  const GridIcons({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContextcontext) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: icon == Icons.ad_units_outlined
          ? Badge(
              label: const Text('up to 25%'),
              textStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.amber,
              alignment: AlignmentDirectional.topStart,
              child: Icon(
                icon,
                color: const Color.fromRGBO(140, 197, 68, 0.85),
                size: 30,
              ),
            )
          : Icon(
              icon,
              color: const Color.fromRGBO(140, 197, 68, 0.85),
              size: 30,
            ),
    );
  }
}

List<Widget> topGridIcon = const [
  GridIcons(icon: Icons.wallet),
  GridIcons(icon: Icons.wallet_giftcard),
  GridIcons(icon: Icons.ad_units_outlined),
  Image(image: AssetImage('images/zemen.jpg'), width: 40),
  Image(image: AssetImage('images/dashen.png'), width: 40),
  Image(
    image: AssetImage('images/cbe.png'),
    width: 40,
  ),
  Image(image: AssetImage('images/siinqee.png'), width: 40),
  Image(image: AssetImage('images/bank.png'), width: 35),
];
List<Widget> bottomGridIcon = const [
  Image(image: AssetImage('images/anniversary.jpg'), width: 40),
  Image(image: AssetImage('images/awash.jpg'), width: 40),
  Image(image: AssetImage('images/merchant.jpg'), width: 40),
  Image(image: AssetImage('images/teleev.jpg'), width: 40),
  Image(image: AssetImage('images/tolo.jpg'), width: 40),
  Image(image: AssetImage('images/aa.png'), width: 40),
  Image(image: AssetImage('images/aa.png'), width: 40),
  Image(image: AssetImage('images/3p.png'), width: 40),
];
