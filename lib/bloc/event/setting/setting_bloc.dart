import 'package:bloc/bloc.dart';
import 'package:eventmanagement/bloc/event/basic/basic_bloc.dart';
import 'package:eventmanagement/model/event/settings/cancellation_option.dart';
import 'package:eventmanagement/model/event/settings/cancellation_policy.dart';
import 'package:eventmanagement/model/event/settings/convenience_charge.dart';
import 'package:eventmanagement/model/event/settings/gst_charge.dart';
import 'package:eventmanagement/model/event/settings/payment_and_taxes.dart';
import 'package:eventmanagement/model/event/settings/setting_response.dart';
import 'package:eventmanagement/model/event/settings/settings_data.dart';
import 'package:eventmanagement/model/event/settings/website_setting.dart';
import 'package:eventmanagement/service/viewmodel/api_provider.dart';
import 'package:eventmanagement/service/viewmodel/mock_data.dart';
import 'package:eventmanagement/utils/vars.dart';

import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final ApiProvider apiProvider = ApiProvider();

  final BasicBloc basicBloc;

  SettingBloc(this.basicBloc);

  void authTokenSave(authToken) {
    add(AuthTokenSave(authToken: authToken));
  }

  void paymentType() {
    add(PaymentType());
  }

  void selectPaymentGatewayBy(paymentBy) {
    add(SelectPaymentGatewayPayBy(paymentBy: paymentBy));
  }

  void convenienceFeeInput(enable) {
    add(SelectConvenienceFee(enable: enable));
  }

  void conveniencePercentInput(input) {
    add(ConveniencePercentageInput(input: input));
  }

  void convenienceAmountInput(input) {
    add(ConvenienceAmountInput(input: input));
  }

  void bookingCancellationInput(enable) {
    add(SelectBookingCancellation(enable: enable));
  }

  void bookingCancellationDescInput(input) {
    add(BookingCancellationDescInput(input: input));
  }

  void addCancellationPolicyOption() {
    add(AddCancellationPolicyOption());
  }

  void removeCancellationPolicyOption(index) {
    add(RemoveCancellationPolicyOption(index: index));
  }

  void cancellationPolicyDeductionType(index, isPercentage) {
    add(CancellationPolicyDeductionType(
        index: index, isPercentage: isPercentage));
  }

  void cancellationPolicyDeductionInput(index, input) {
    add(CancellationPolicyDeductionInput(index: index, input: input));
  }

  void cancellationPolicyEndDate(index, dateTime) {
    add(CancellationPolicyEndDate(index: index, dateTime: dateTime));
  }

  void bookingTransferInput(enable) {
    add(SelectBookingTransfer(enable: enable));
  }

  void remainingTicketsInput(enable) {
    add(SelectRemainingTickets(enable: enable));
  }

  void registrationLabelInput(input) {
    add(RegistrationLabelInput(input: input));
  }

  void facebookLinkInput(input) {
    add(FacebookLinkInput(input: input));
  }

  void twitterLinkInput(input) {
    add(TwitterLinkInput(input: input));
  }

  void linkedInLinkInput(input) {
    add(LinkedInLinkInput(input: input));
  }

  void websiteLinkInput(input) {
    add(WebsiteLinkInput(input: input));
  }

  void tncInput(input) {
    add(TnCInput(input: input));
  }

  void uploadSettings(callback) {
    add(UploadSettings(callback: callback));
  }

  @override
  SettingState get initialState => SettingState.initial();

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    if (event is AuthTokenSave) {
      yield state.copyWith(authToken: event.authToken);
    }

    if (event is PaymentType) {
      yield state.copyWith(paymentTypeList: getPaymentType());
    }

    if (event is SelectPaymentGatewayPayBy) {
      yield state.copyWith(paymentGatewayPayPerson: event.paymentBy);

      int id = state.paymentTypeList.indexWhere(
              (item) => item.value == state.paymentGatewayPayPerson.value);

      state.paymentTypeList.forEach((element) => element.isSelected = false);
      state.paymentTypeList[id].isSelected = true;

      yield state.copyWith(paymentTypeList: state.paymentTypeList);
    }

    if (event is SelectConvenienceFee) {
      yield state.copyWith(convenienceFee: event.enable);
    }

    if (event is ConveniencePercentageInput) {
      yield state.copyWith(percentValue: event.input);
    }

    if (event is ConvenienceAmountInput) {
      yield state.copyWith(convenienceAmount: event.input);
    }

    if (event is SelectBookingCancellation) {
      yield state.copyWith(bookingCancellation: event.enable);
    }

    if (event is BookingCancellationDescInput) {
      yield state.copyWith(cancellationPolicyDesc: event.input);
    }

    if (event is AddCancellationPolicyOption) {
      final options = List.of(state.cancellationOptions);
      options.add(CancellationOption(refundType: 'amount', refundValue: '0'));
      yield state.copyWith(cancellationOptions: options);
    }

    if (event is RemoveCancellationPolicyOption) {
      final options = List.of(state.cancellationOptions);
      options.removeAt(event.index);
      yield state.copyWith(cancellationOptions: options);
    }

    if (event is CancellationPolicyDeductionType) {
      final cancellationOptions = List.of(state.cancellationOptions);
      final cancellationOption = cancellationOptions[event.index];
      final newOption =
      CancellationOption.fromJson(cancellationOption.toJson());
      newOption.refundType = event.isPercentage ? 'percentage' : 'amount';
      cancellationOptions.removeAt(event.index);
      cancellationOptions.insert(event.index, newOption);
      yield state.copyWith(cancellationOptions: cancellationOptions);
    }

    if (event is CancellationPolicyDeductionInput) {
      final cancellationOption = state.cancellationOptions[event.index];
      cancellationOption.refundValue = event.input;
    }

    if (event is CancellationPolicyEndDate) {
      final cancellationOption = state.cancellationOptions[event.index];
      final newOption =
      CancellationOption.fromJson(cancellationOption.toJson());
      newOption.cancellationEndDate = event.dateTime;
      state.cancellationOptions.removeAt(event.index);
      state.cancellationOptions.insert(event.index, newOption);
      yield state.copyWith(cancellationOptions: state.cancellationOptions);
    }

    if (event is SelectBookingTransfer) {
      yield state.copyWith(transferBooking: event.enable);
    }

    if (event is SelectRemainingTickets) {
      yield state.copyWith(remaningTickets: event.enable);
    }

    if (event is RegistrationLabelInput) {
      yield state.copyWith(bookButtonLabel: event.input);
    }

    if (event is FacebookLinkInput) {
      yield state.copyWith(facebookLink: event.input);
    }

    if (event is TwitterLinkInput) {
      yield state.copyWith(twitterLink: event.input);
    }

    if (event is LinkedInLinkInput) {
      yield state.copyWith(linkdinLink: event.input);
    }

    if (event is WebsiteLinkInput) {
      yield state.copyWith(websiteLink: event.input);
    }

    if (event is TnCInput) {
      yield state.copyWith(tnc: event.input);
    }

    if (event is UploadSettings) {
      try {
        int errorCode = validateSettingsInfo();

        if (errorCode > 0) {
          yield state.copyWith(errorCode: errorCode);
          event.callback(null);
          return;
        }

        await apiProvider.uploadSettings(state.authToken, settingDataToUpload,
            eventDataId: basicBloc.eventDataId);

        yield state.copyWith(loading: false);

        if (apiProvider.apiResult.responseCode == ok200) {
          var settingResponse =
          apiProvider.apiResult.response as SettingResponse;
          event.callback(settingResponse);
        } else {
          event.callback(apiProvider.apiResult.errorMessage);
        }
      } catch (error) {
        print('Exception Occured--->$error');
        yield state.copyWith(errorCode: ERR_SOMETHING_WENT_WRONG);
        event.callback(null);
      }
    }
  }

  int validateSettingsInfo() {
    if (state.bookingCancellation) {
      if (!isValid(state.cancellationPolicyDesc)) return ERR_CANCELLATION_DESC;
      if (state.cancellationOptions.length == 0) return ERR_CANCELLATION_OPTION;
    }
    if (!state.tnc) return ERR_TNC;
    return 0;
  }

  SettingData get settingDataToUpload =>
      SettingData(
          status: 'ACTIVE',
          paymentAndTaxes: PaymentAndTaxes(
              gstCharge: GSTCharge.defaultInstance(),
              convenienceCharge: ConvenienceCharge(
                percentValue: state.percentValue,
                value: state.convenienceAmount,
                enable: state.convenienceFee,
                precentage: false,
              )),
          cancellationPolicy: CancellationPolicy(
            description: state.cancellationPolicyDesc,
            options: state.cancellationOptions,
          ),
          websiteSettings: WebsiteSetting(
            paymentGatewayPayPerson: state.paymentGatewayPayPerson.value,
            bookingCancellation: state.bookingCancellation,
            bookingUpgradation: false,
            transferBooking: state.transferBooking,
            remaningTickets: state.remaningTickets,
            bookButtonLabel: state.bookButtonLabel,
            facebookLink: state.facebookLink,
            linkdinLink: state.linkdinLink,
            twitterLink: state.twitterLink,
            websiteLink: state.websiteLink,
            showDateTime: true,
            showLocation: true,
            showPrice: true,
          ));
}
