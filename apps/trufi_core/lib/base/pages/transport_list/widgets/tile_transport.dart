import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

class TileTransport extends StatelessWidget {
  final TransitRoute patternOtp;
  final GestureTapCallback onTap;

  const TileTransport({
    super.key,
    required this.patternOtp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: patternOtp.route?.backgroundColor,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(5)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              patternOtp.route?.shortName ?? '',
                              style: TextStyle(
                                color: patternOtp.route?.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              patternOtp.route?.longNameLast ?? '',
                              style: TextStyle(
                                color: patternOtp.route?.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: theme.appBarTheme.backgroundColor,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(5)),
                      ),
                      child: patternOtp.route!.mode?.getImage(
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(5),
                      top: Radius.circular(0),
                    ),
                  ),
                  alignment: FractionalOffset.centerLeft,
                  child: Text(
                    patternOtp.route?.longName ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
            width: 30,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
