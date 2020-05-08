import 'package:bloc/bloc.dart';
import 'package:eventmanagement/model/event/tickets/ticket_action_response.dart';
import 'package:eventmanagement/model/event/tickets/tickets.dart';
import 'package:eventmanagement/service/viewmodel/api_provider.dart';
import 'package:eventmanagement/utils/vars.dart';

import 'tickets_event.dart';
import 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final ApiProvider apiProvider = ApiProvider();
  String eventDataId;

  void authTokenSave(authToken) {
    add(AuthTokenSave(authToken: authToken));
  }

  void populateExistingEvent(ticketList) {
    add(PopulateExistingEvent(ticketList: ticketList));
  }

  void tickets() {
    add(Tickets());
  }

  void addTicket(Ticket ticket) {
    add(AddTicket(ticket));
  }

  void updateTicket(Ticket ticket) {
    add(UpdateTicket(ticket));
  }

  void deleteTicket(String ticketId, Function callback) {
    add(DeleteTicket(ticketId, callback));
  }

  void activeInactiveTicket(String ticketId, bool active, Function callback) {
    add(ActiveInactiveTicket(ticketId, active, callback));
  }

  @override
  TicketsState get initialState => TicketsState.initial();

  @override
  Stream<TicketsState> mapEventToState(TicketsEvent event) async* {
    if (event is AuthTokenSave) {
      yield state.copyWith(authToken: event.authToken);
    }

    if (event is PopulateExistingEvent) {
      yield state.copyWith(ticketsList: List.of(event.ticketList));
    }

    if (event is AddTicket) {
      state.ticketsList.add(event.ticket);
      yield state.copyWith(ticketsList: List.of(state.ticketsList));
    }

    if (event is UpdateTicket) {
      int removeIndex = state.ticketsList
          .indexWhere((ticket) => ticket.sId == event.ticket.sId);
      state.ticketsList.removeAt(removeIndex);
      state.ticketsList.insert(removeIndex, event.ticket);
      yield state.copyWith(ticketsList: List.of(state.ticketsList));
    }

    if (event is DeleteTicket) {
      deleteTicketApi(event);
    }

    if (event is DeleteTicketResult) {
      if (event.success) {
        state.ticketsList.removeWhere((ticket) => ticket.sId == event.ticketId);

        yield state.copyWith(
            ticketsList: List.of(state.ticketsList),
            loading: false,
            uiMsg: event.uiMsg);
      } else {
        yield state.copyWith(loading: false, uiMsg: event.uiMsg);
      }
    }

    if (event is ActiveInactiveTicket) {
      activeInactiveTicketApi(event);
    }

    if (event is ActiveInactiveTicketResult) {
      if (event.success) {
        final ticket = state.ticketsList
            .firstWhere((ticket) => ticket.sId == event.ticketId);
        ticket.active = event.active;

        yield state.copyWith(
            ticketsList: List.of(state.ticketsList),
            loading: false,
            uiMsg: event.uiMsg);
      } else {
        yield state.copyWith(loading: false, uiMsg: event.uiMsg);
      }
    }

    if (event is Tickets) {
      yield state.copyWith(loading: true);

      yield state.copyWith(
        ticketsList: state.ticketsList ?? [],
        loading: false,
      );
    }
  }

  void deleteTicketApi(DeleteTicket event) {
    apiProvider
        .deleteTicket(state.authToken, event.ticketId)
        .then((networkServiceResponse) {
      if (networkServiceResponse.responseCode == ok200) {
        final ticketActionResponse =
        networkServiceResponse.response as TicketActionResponse;
        if (ticketActionResponse.code == apiCodeSuccess) {
          add(DeleteTicketResult(true,
              ticketId: event.ticketId, uiMsg: ticketActionResponse.message));
          event.callback(ticketActionResponse);
        } else {
          add(DeleteTicketResult(false,
              uiMsg: ticketActionResponse.message ?? ERR_SOMETHING_WENT_WRONG));
          event.callback(ticketActionResponse);
        }
      } else {
        add(DeleteTicketResult(false,
            uiMsg: networkServiceResponse.error ?? ERR_SOMETHING_WENT_WRONG));
        event.callback(networkServiceResponse.error);
      }
    }).catchError((error) {
      print('Error in deleteTicketApi--->$error');
      add(DeleteTicketResult(false, uiMsg: ERR_SOMETHING_WENT_WRONG));
      event.callback(ERR_SOMETHING_WENT_WRONG);
    });
  }

  void activeInactiveTicketApi(ActiveInactiveTicket event) {
    apiProvider
        .activeInactiveTickets(state.authToken, event.active, event.ticketId)
        .then((networkServiceResponse) {
      if (networkServiceResponse.responseCode == ok200) {
        final ticketActionResponse =
        networkServiceResponse.response as TicketActionResponse;

        if (ticketActionResponse.code == apiCodeSuccess) {
          add(ActiveInactiveTicketResult(
            true,
            ticketId: event.ticketId,
            active: event.active,
            uiMsg: ticketActionResponse.message,
          ));
          event.callback(ticketActionResponse);
        } else {
          add(ActiveInactiveTicketResult(
            false,
            uiMsg: ticketActionResponse.message ?? ERR_SOMETHING_WENT_WRONG,
          ));
          event.callback(ticketActionResponse);
        }
      } else {
        add(ActiveInactiveTicketResult(
          false,
          uiMsg: networkServiceResponse.error ?? ERR_SOMETHING_WENT_WRONG,
        ));
        event.callback(networkServiceResponse.error);
      }
    }).catchError((error) {
      print('Error in activeInactiveTicketApi--->$error');
      add(ActiveInactiveTicketResult(false, uiMsg: ERR_SOMETHING_WENT_WRONG));
      event.callback(ERR_SOMETHING_WENT_WRONG);
    });
  }
}
