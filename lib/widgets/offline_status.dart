import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/request_manager_bloc.dart';

class OfflineStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requestManagerBloc = RequestManagerBloc.of(context);
    return StreamBuilder<OfflineRequestManagerStatus>(
      stream: requestManagerBloc.offline.outStatusUpdate,
      builder: (
        BuildContext context,
        AsyncSnapshot<OfflineRequestManagerStatus> snapshot,
      ) {
        final status = requestManagerBloc.offline.status;
        if (status == OfflineRequestManagerStatus.failed) {
          return _buildErrorStatus(context);
        } else if (status == OfflineRequestManagerStatus.preparing) {
          return _buildPreparingStatus(context);
        }
        return Container();
      },
    );
  }

  Widget _buildPreparingStatus(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 48.0,
      child: Row(
        children: [
          Icon(Icons.cloud_off),
          SizedBox(width: 8.0),
          Text(
            "Preparing offline mode...",
            style: theme.primaryTextTheme.caption,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(BuildContext context) {
    final requestManagerBloc = RequestManagerBloc.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 48.0,
      child: Row(
        children: [
          Icon(Icons.cloud_off),
          SizedBox(width: 8.0),
          Text(
            "Preparing offline mode failed",
            style: theme.primaryTextTheme.caption,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: RaisedButton(
              child: Text("Retry"),
              onPressed: requestManagerBloc.offline.reset,
            ),
          ),
        ],
      ),
    );
  }
}
