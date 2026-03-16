import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum OtpIconAsset {
  bag,
  bell,
  noteWithPen,
  settings,
  message,
  scan,
  scannerQr,
  exit,
  magnifier,
  star,
  trash,
  wifi,
  noWifi,
  link,
  unlink,
  pen,
  printer,
  signature,
  spanner,
  mark,
  unmark,
}

String _otpIconPath(OtpIconAsset icon) {
  switch (icon) {
    case OtpIconAsset.bag:
      return 'assets/img/icons/bag.svg';
    case OtpIconAsset.bell:
      return 'assets/img/icons/bell.svg';
    case OtpIconAsset.noteWithPen:
      return 'assets/img/icons/note_with_pen.svg';
    case OtpIconAsset.settings:
      return 'assets/img/icons/settings.svg';
    case OtpIconAsset.message:
      return 'assets/img/icons/message.svg';
    case OtpIconAsset.scan:
      return 'assets/img/icons/scan.svg';
    case OtpIconAsset.scannerQr:
      return 'assets/img/icons/scannerqr.svg';
    case OtpIconAsset.exit:
      return 'assets/img/icons/exit.svg';
    case OtpIconAsset.magnifier:
      return 'assets/img/icons/magnifier.svg';
    case OtpIconAsset.star:
      return 'assets/img/icons/star.svg';
    case OtpIconAsset.trash:
      return 'assets/img/icons/trash.svg';
    case OtpIconAsset.wifi:
      return 'assets/img/icons/wifi.svg';
    case OtpIconAsset.noWifi:
      return 'assets/img/icons/no_wifi.svg';
    case OtpIconAsset.link:
      return 'assets/img/icons/link.svg';
    case OtpIconAsset.unlink:
      return 'assets/img/icons/unlink.svg';
    case OtpIconAsset.pen:
      return 'assets/img/icons/pen.svg';
    case OtpIconAsset.printer:
      return 'assets/img/icons/printer.svg';
    case OtpIconAsset.signature:
      return 'assets/img/icons/signature.svg';
    case OtpIconAsset.spanner:
      return 'assets/img/icons/spanner.svg';
    case OtpIconAsset.mark:
      return 'assets/img/icons/mark.svg';
    case OtpIconAsset.unmark:
      return 'assets/img/icons/unmark.svg';
  }
}

class OtpIcon extends StatelessWidget {
  const OtpIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticsLabel,
  });

  final OtpIconAsset icon;
  final double? size;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24;
    final resolvedColor = color ?? iconTheme.color;

    return SvgPicture.asset(
      _otpIconPath(icon),
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: resolvedColor == null ? null : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      semanticsLabel: semanticsLabel,
    );
  }
}
