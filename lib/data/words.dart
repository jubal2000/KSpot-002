import 'package:get/get.dart';

class Words extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'Follow1': 'Follower',
      'Follow2': 'Follow',
      'Report ready': 'Ready',
      'Report progress': 'Progress',
      'Report reject': 'Reject',
      'Report done': 'Done',
    },
    'ko_KR': {
      // main tab
      'SPOT': '스팟',
      'EVENT': '이벤트',
      'STORY': '스토리',
      'CLASS': '강습',
      'MY SPOT': '내 스팟',
      'MY EVENT': '내 이벤트',
      'MY STORY': '내 스토리',
      'PROFILE': '프로필',
      'FOLLOW': '팔로우',
      'FOLLOWER': '팔로워',
      'FOLLOW LIST': '팔로우 목록',
      'BOOKMARK': '북마크',
      'LIKE': '북마크',
      'NEW STORY': 'NEW 스토리',
      'HOT STORY': 'HOT 스토리',
      'APP SETTING': '앱 설정',
      'GOODS LIST': '상품목록',
      'PROMOTION SPOT': '프로모션 스팟',
      'SELECT SPOT': '스팟 선택',
      'SELECTED SPOT': '선택 스팟',
      'CATEGORY': '카테고리',
      'SPOT GROUP': '스팟 그룹',
      'USER': '유저',
      'MESSAGE': '메시지',
      'MESSAGE BOX': '메시지함',
      'PROFILE EDIT': '프로필 편집',
      'Message box': '메시지함',
      'Spot group': '스팟 그룹',
      'Spot': '스팟',
      'MY': '내정보',

      // intro_screen
      'SIGN IN': '로그인',
      'SIGNUP': '회원가입',
      'START': '시작',
      'GUEST START': '바로 시작하기',

      // signup_screen
      'Agree to Terms and Conditions': '약관 동의',
      'Place Setting': '장소 설정',
      'Login phone number verification': '로그인 전화번호 인증',
      'Please enter your registered phone number': '회원가입된 전화번호를 입력해 주세요',

      // event_screen
      'Enable': '활성화',
      'Disable': '비활성화',
      'Enable spot?': '스팟을 활성화 하시겠습니까?',
      'Disable spot?': '스팟을 비활성화 하시겠습니까?',
      'In the disable state, other users cannot see it': '비활성화 시, 다른 유저에게 보이지 않습니다',
      'Event period has ended': '이벤트 기간이 종료 되었습니다',
      'Event edited': '이벤트 수정완료',
      'Event duration must be modified': '이벤트 기간을 수정해야 합니다',
      'Enabled': '활성화됨',
      'Disabled': '비활성화됨',
      'RESERVATION LIST': '예약 목록',
      'Event Add': '이벤트 추가',
      'Event Edit': '이벤트 수정',
      'Event Information': '이벤트 정보',
      'Please enter select picture..': '이벤트 사진을 선택해 주세요..',
      'Please enter event title..': '이벤트 제목을 입력해 주세요..',
      'Please enter event description..': '이벤트 내용을 입력해 주세요..',
      'Please enter event time..': '이벤트 시간을 입력해 주세요..',
      'Please enter select manager..': '이벤트 관리자를 선택해 주세요..',
      'TITLE': '제목',
      'IMAGE': '사진',
      '[first]': '[대표이미지]',
      'Upload Failed': '업로드 실패',
      'Event Upload Failed': '이벤트 업로드에 실패했습니다',
      'Event Upload Complete': '이벤트 업로드 완료',

      // main_event
      'There are no events': '이벤트가 없습니다',
      'Select event': '이벤트 선택',

      // main_myprofile
      'Profile image': '프로필 사진',
      'Photo update is complete': '사진 업데이트가 완료되었습니다',
      'Edit message': '메시지 수정',
      'Enter your message to show here': '여기에 보여줄 메시지를 입력하세요',

      // setup_screen
      'Profile edit': '프로필 편집',
      'Contact edit': '연락처 편집',
      'SNS link edit': 'SNS 링크 편집',
      'Notification setting': '알림 설정',
      'Content setting': '컨텐츠 설정',
      'Declare/Report list': '차단/신고 목록',
      'Contact us': '문의하기',
      'Notice': '공지사항',
      'faq': '자주묻는 질문',
      'FAQ': '자주묻는 질문',
      'terms': '이용 약관',
      'Withdrawal': '회원탈퇴',
      'Sign out': '로그아웃',
      'SIGN OUT': '로그아웃',
      'Sign out done': '로그아웃 완료',
      'Would you like to sign out now?': '지금 로그아웃 하시겠습니까?',
      'Promotion list': '홍보 기록',
      'Terms': '이용 약관',
      'Phone number verification': '전화번호 인증',

      // target_profile
      'Would you like to follow?': '팔로우 하시겠습니까?',

      // main_place
      'No events for that day': '선택한 날짜에 이벤트가 없습니다',
      'No place to choose': '선택할 장소가 없습니다',
      'No place data': '장소 데이터가 없습니다',
      'Don\'t choose now': '지금 선택하지 않습니다',
      '(You can choose later)': '(나중에 선택할 수 있습니다)',

      // place_screen
      'MANAGER': '관리자',
      'MANAGER *': '관리자 *',
      'ADDRESS': '주소',
      'My Location': '내 위치',
      'PHONE': '전화번호',
      'EMAIL': '이메일',
      'SCHEDULE': '일정',
      'PLACE & LOCATION': '장소 & 위치',
      'COMMENT': '댓글',
      'SELECT EVENT': '이벤트 선택',
      'EXPIRED': '기간초과',
      'PLACE SETTING': '장소 설정',
      'EVENT GROUP SELECT': '이벤트 그룹 선택',
      'EVENT PLACE SELECT': '이벤트 장소 선택',
      'PLACE\nSELECT': '이벤트\n장소선택',
      'GROUP\nSELECT': '이벤트\n그룹선택',

      // place_edit
      'PLACE INFO': '장소 정보',

      'BANNER SETTING': '베너 설정',

      // event_time_select_screen
      'Every': '전체',
      '1st': '첫째주',
      '2nd': '둘째주',
      '3rd': '셋째주',
      '4th': '넷째주',
      'Last': '마지막주',
      'Mon':'월',
      'Tue':'화',
      'Wed':'수',
      'Thu':'목',
      'Fri':'금',
      'Sat':'토',
      'Sun':'일',
      'SELECT DAYS': '날짜 선택',
      'SELECT PERIOD': '기간 선택',
      'Are you sure you want to delete that date?': '해당 날짜를 삭제 하시겠습니까?',
      'Are you sure you want to delete that field?': '해당 필드를 삭제 하시겠습니까?',
      'ADD TIME': '시간 추가',
      'SET TIME': '시간 편집',
      'Start date': '시작일',
      'End date': '종료일',
      'Start time': '시작시간',
      'End time': '종료시간',
      '(You can choose only one type)': '(한가지 타입만 선택 가능)',
      'TIME SELECT': '시간 선택',

      // place_event_edit_screen
      'INFO': '기본 정보',
      'TYPE SELECT': '타입 선택',
      'RESERVATION INFO': '예약 정보',
      'THUMBNAIL IMAGE *': '대표 이미지 *',
      'THUMBNAIL IMAGE(Small Size, MAX 1)': '대표 이미지(작은사이즈, 최대 1)',
      'BANNER IMAGES(MAX 9)': '배너 이미지(최대 9)',
      'THEME': '테마',
      'Event Title *': '이벤트 제목*',
      'Event Description': '이벤트 내용',
      'Class title *': '강습 제목*',
      'Please enter a title': '제목을 입력해 주세요',
      'Description': '내용 입력',
      'ENTRANCE FEE(site)': '입장료(현장)',
      'Amount': '수량',
      'SEARCH TAG': '검색 태그',
      'Search Tag': '검색 태그',
      'OPTIONS': '옵션',
      'Do you want to upload now?': '지금 업로드 하시겠습니까?',
      'Do you want to update now?': '지금 수정 하시겠습니까?',
      'Photo Add': '사진 추가',
      'Photo add *': '사진 추가 *',

      // edit_list_widget
      'ADDRESS LINK': '주소 링크',
      'SPOT LINK': '스팟 링크',
      'FOLLOW LINK': '팔로우 링크',
      'EVENT LINK': '이벤트 링크',
      'GOODS DESCRIPTION': '상품 설명',
      'GOODS INFO': '상품 정보',
      'SNS LINK': 'SNS 링크',
      'INSTRUCTOR': '강사',
      'EVENT FIELD': '이벤트 내용',
      'TIME SETTING': '시간 설정',
      'TIME SETTING *': '시간 설정 *',
      'DATE SELECT': '날짜 선택',
      'EXCEPT DATE SELECT': '예외 날짜 선택',
      'RESERVATION': '예약하기',
      'CUSTOM FIELD': '기타 입력',
      'Fields that can be entered as default when adding an event at a venue (eg Party DJ)': '장소에서 이벤트 추가시 기본으로 입력할 수 있는 필드(예: 파티 DJ',
      'FOLLOWER SELECT': '팔로워 선택',
      'PRICE': '금액',
      'Price': '금액',
      'Text input field': '입력 필드',
      'Title': '제목',
      'Desc': '내용',
      'File upload': '파일 업로드',
      'EVENT PHOTO *': '이벤트 사진 *',

      // place_edit_screen
      'SPOT ADD': '스팟 추가',
      'SPOT EDIT': '스팟 편집',
      '[FIRST]': '[대표]',
      'Title *': '제목 *',
      'COUNTRY / STATE, CITY *': '국가 / 도시 *',
      'Address *': '주소 *',
      'Address detail *': '상세 주소 *',
      'Please enter your address': '주소를 입력해 주세요',
      'Please enter your detailed address': '상세 주소를 입력해주세요',
      'Email': '이메일',
      'Phone': '전화번호',
      'CONTACT': '연락처',

      // place_list_screen
      'PLACE LIST': '장소 목록',

      // place_group_edit_screen
      'SPOT GROUP ADD': '스팟 그룹 추가',
      'Spot Group Title *': '스팟 그룹 이름 *',

      // signin_edit_screen
      'Sign in': '로그인',
      'Please enter email': '이메일을 입력해 주세요',
      'Password': '패스워드',
      'Please enter password': '패스워드를 입력해 주세요',
      'Sign up': '계정생성',
      'Sign up failed': '계정생성에 실패했습니다',
      'Sign in failed': '로그인에 실패했습니다',
      'EMAIL SIGN UP': '이메일로 계정생성',
      'Email sign up': '이메일로 계정생성',
      'Female': '여성',
      'Male': '남성',
      'No select': '선택안함',
      'Please check text length': '입력한 문자의 길이를 확인해주세요',
      'Please check email': '입력한 이메일을 확인해주세요',
      'Nickname': '닉네임',
      'NICKNAME': '닉네임',
      'Name': '이름',
      'Please enter nickname': '닉네임을 2자 이상 입력해 주세요',
      'Please enter name': '이름을 2자 이상 입력해 주세요',
      'GENDER(or PART)': '성별 (혹은 역할)',
      'BIRTH YEAR': '탄생 년도',
      'Consent to use': '사용 동의',
      'Terms of service': '서비스 약관',
      'Terms of use': '이용 약관',
      'I agree to the terms and conditions': '이용약관에 동의 합니다',
      'Personal Information Collection and Terms of Use': '이용 약관',
      'I agree to the Privacy Policy': '개인정보 약관에 동의 합니다',
      'Next': '다음',
      'min': '최소',
      'max': '최대',
      'INPUT TYPE': '입력 형식',
      'This is the authentication step': '인증 단계입니다',
      'This is the last step': '마지막 단계입니다',
      'Experience the many services and benefits of KSpot':
      'KSpot의 많은 서비스와 혜택을 체험해보세요',
      'Congratulations on your membership': '회원가입을 축하합니다',
      'Select Done': '선택 완료',

      // slide_timepicker_screen
      'Select Time Range': '시간 범위 선택',
      'START TIME': '시작 시간',
      'END TIME': '종료 시간',

      // story_edit_screen
      'SELECT CONTENT TYPE': '컨텐츠 타입 선택',
      'VIDEO': '비디오',
      'Delete completed': '삭제 완료',
      'Delete failed': '삭제 실패',
      'SPOT SELECT': '스팟 선택',
      'EVENT SELECT': '이벤트 선택',
      'IMAGE SELECT *': '사진 선택 *',
      'IMAGE SELECT': '사진 선택',
      'Please select one or more images': '하나 이상의 사진을 선택해 주세요',
      'TAG': '태그',
      'DESC': '내용',
      'Save': '저장',
      'Message': '메시지',
      'Would you like to send a message?': '메시지를 보내시겠습니까?',
      'Would you like to save?': '저장 하시겠습니까?',
      'Spot select': '스팟 선택',
      'Event select': '이벤트 선택',
      '[Del/Edit]': '[삭제/수정]',
      '[Comment]': '[댓글]',
      '[Answer]': '[답변]',
      'Answer': '답변',

      // video_picker_screen
      'Failed to select video': '비디오 선택 실패',
      'Video cover': '비디오 대표이미지',
      'Create cover fail': '대표이미지 생성 실패',
      'Trim': '자르기',
      'Cover': '대표이미지',
      'Processing': '처리중',
      'Video Select': '비디오 선택',
      'Please select a video to upload': '업로드 할 비디오를 선택해주세요',
      'Select from my phone': '내 폰에서 선택',

      // follow_screen
      'Follow cancel': '팔로우 취소',
      'Are you sure you want to unfollow?': '팔로우를 취소하시겠습니까?',
      'Please select a target': '대상을 선택해 주세요',
      'Please select targets': '대상을 선택해 주세요',

      // history_screen
      'Maximum number of selections': '더 이상 선택할수 없습니다',
      'History list': '히스토리 목록',

      // message_screen
      'To black': '차단하기',
      'Are you sure you want to block that user?': '해당 유저를 차단 하시겠습니까?',
      'Target': '대상',
      'The user has been blocked': '해당 유저가 차단되었습니다',
      'Report it': '신고하기',
      'Report content': '내용 신고하기',
      'Change to Ownership': '소유자 변경요청',
      'Already been reported user': '이미 신고된 유저입니다',
      'Please fill out the report': '신고 내용을 작성해 주세요',
      'The user has been reported': '해당 유저 신고가 완료되었습니다',
      'Target user': '대상 유저',
      'Following': '내가 팔로우',
      'Follower': '나를 팔로우',
      'Follow': '팔로우',
      'Remove': '삭제',
      'Image': '사진',
      'Remove all images?': '모든 사진을 삭제하시겠습니까?',
      'You can\'t add any more': '더 이상 추가할 수 없습니다',
      'Send': '전송',
      'SEND': '전송',
      'RESEND': '재전송',
      'READ': '읽음',

      // promotion_list_screen
      'PROMOTION RECORD': '홍보 기록',
      'PROMOTION START': '홍보 시작',

      // promotion_screen
      'PROMOTION': '홍보하기',
      'CANCEL & REFUND': '취소 & 환불',
      'CANCEL': '취소',
      'It will be processed after confirmation by the person in charge': '담당자 확인후 처리됩니다',
      'Request has been completed': '요청이 완료되었습니다',
      'Request has been failed': '요청이 실패했습니다',
      'Confirm payment': '임금확인',
      'Confirmation of payment?': '입금확인이 완료되었습니까?',
      'Confirmation that the deposit has been completed': '입금 확인이 완료됬습니다',
      'Deposit confirm failed': '입금확인에 실패했습니다',
      'Deposit Cancel': '입금 취소',
      'Promotion stop': '홍보 중지',
      'Promotion service stop?': '홍보를 중지하시겠습니까?',
      'Promotion has stopped': '홍보가 중지되었습니다',
      'Promotion stop failed': '홍보 중지에 실패했습니다',
      'Are you sure you want to delete it now?': '지금 삭제하시겠습까?',
      '(After deletion, it is not visible in the list)': '(삭제후에는 목록에서 보이지않습니다)',
      'TOTAL PRICE': '총 금액',
      'PROMOTION PERIOD': '홍보 기간',
      'DEPOSIT ACCOUNT INFO': '입금 계좌 정보',
      'TAX SETTLEMENT': '세금 정산',
      'Tax bill': '세금 계산서',
      '(send to email)': '(이메일로 회신)',
      'Cash receipts': '현금 영수증',
      '(use phone number)': '(전화번호 이용)',
      'CONTACT US': '문의처',
      'Send message': '문의 보내기',
      'Promotion': '홍보하기',
      'Ads will be applied once payment is confirmed': '입금이 확인되면 광고가 적용됩니다',
      'CREATE TIME': '생성 시간',
      'Reservation': '예약',
      'Reservation request completed': '예약신청 완료',
      'Reservation cancel': '예약 취소',
      'Are you sure you want to cancel your reservation?': '예약을 취소하시겠습니까?',
      'Cancel message': '취소 메시지',
      'Your cancellation request has been completed': '취소 요청이 완료됬습니다',
      'Cancellation request failed': '취소 요청이 실패했습니다',
      'Reservation delete': '예약 삭제',
      'Deletion is complete': '삭제가 완료되었습니다',
      'Are you sure you want to delete your reservation?': '예약을 삭제하시겠습니까?',
      'Would you like to make a reservation?': '예약 하시겠습니까?',

      // reserve_my_screen
      'MY RESERVATION': '내 예약',
      'RESERVATION RECEIVED' : '받은 예약',
      'CANCELED': '취소됨',
      'BOOKED': '예약됨',
      'READY': '대기중',
      'WAITING': '대기중',
      'People': '명',
      'Peoples': '명',
      'Comment': '댓글',
      'Manager Comment': '관리자 댓글',
      'Cancel Comment': '취소 댓글',

      // reserve_screen
      'Canceled': '취소됨',
      'Reservation code': '예약코드',
      'RESERVATION AMOUNT': '예약금액',
      'RESERVATION DATE': '예약일',
      'TOTAL NUMBER OF PEOPLE': '예약인원',
      '(self include)': '(본인포함)',
      'CONFIRM TIME': '확인 시간',
      'CANCEL TIME': '취소 시간',
      'Would you like to confirm your reservation?': '예약 확인 하시겠습니까?',
      'Reservation confirmed': '예약이 확인 되었습니다',
      'Reservation confirm failed': '예약 확인에 실패했습니다',
      'Reservation send': '예약 신청',
      'Reservation confirm': '예약 확인',
      'USER INFO': '유저정보',
      'Reservation comment': '에약 코멘트',
      '(On-site payment)': '(현장 결제)',
      'Reservation failed': '예약 실패',
      'Reservation reject': '예약 실패',
      'Would you like to reject this reservation?': '이 예약을 거부하시겠습니까?',
      'Reservation rejected': '예약 거절 완료',
      'Reservation reject failed': '예약 거절 실패',
      'Failed': '실패함',
      'Declined': '실패함',
      'Cancellation pending': '취소 대기중',
      'Confirmed': '확정됨',
      'Waiting': '대기중',
      'Reservation cancellation completed': '예약 취소가 완료되었습니다',
      'Confirm Message': '예약 확인 메시지',
      'CANCEL WAITING': '취소 대기중',

      // setup_profile_screen
      'NAME': '이름',
      'Please check length': '길이를 확인해 주세요',
      'DEPOSIT & REFUND INFO': '입금 & 환불 정보',
      'Bank title': '은행명',
      'Bank account(number only)': '계좌번호(숫자만 입력)',
      'Real name': '계좌실명',
      'Do you want to save the modified profile?': '수정된 프로필을 저장하시겠습니까?',
      'Block date': '차단일시',
      'Report date': '신고일시',

      // setup_block_screen
      'Block list': '차단 목록',
      'Report list': '신고 목록',
      'Unblock': '차단해제',
      'Do you want to unblock?': '차단을 해제 하시겠습니까?',
      'Unblocking is complete': '차단해제가 완료되었습니다',
      'View report': '신고내용 보기',
      'Report': '신고',
      'Report cancel': '신고 취소',
      'Report ready': '대기중',
      'Report progress': '처리중',
      'Report reject': '보류됨',
      'Report done': '처리완료',
      'Report is pending': '신고가 접수 대기중입니다',
      'Report has been received and is being processed': '신고가 접수되어 처리중입니다',
      'Report has been rejected': '신고가 보류되었습니다',
      'Report has been processed': '신고가 처리 완료되었습니다',

      // setup_contact_screen
      'Verify link has been sent': '인증 ',
      'Verification link has been sent': '확인 링크가 전송되었습니다',
      'Email verify': '이메일 확인',
      'Send email verify error': '이메일 인증 오류',
      'Email already in use': '이미 사용중인 이메일입니다',
      'Phone verify': '전화번호 확인',
      'Send phone verify error': '전화번호 인증 발송 실패',
      'Phone verify error': '전화번호 인증 실패',
      'Phone number already in use': '이미 사용중인 전화번호입니다',
      'Phone number is not valid': '잘못된 전화번호입니다',
      'Verify code send failed': '인증코드 발송 오류',
      'Verify code sent complete': '인증코드가 발송되었습니다',
      'Invalid verification code': '잘못된 인증코드입니다',
      'Re-login is required': '재로그인이 필요합니다',
      'Email verify done': '이메일 인증 완료',
      'Need email verify': '이메일 인증이 필요',
      'Waiting for email validate': '이메일 인증 대기중',
      '(Check your email or spam box)': '(이메일 상자나 스팸보관함 확인)',
      'Need phone verify': '전화번호 인증',
      'Phone change completed': '전화번호 변경 완료',
      'Too many requests': '이미 전송되었습니다',

      // setup_play_screen
      'STORY PLAY SETTING': '스토리 재생 설정',

      // setup_push_screen
      'Push notification': '푸쉬 알림',

      // setup_sns_screen
      'SNS Link add': 'SNS 링크추가',

      // place_group_edit_screen
      'Field add': '필드 추가',
      'Field title': '필드 제목',
      'Field type': '필드 형식',
      'Spot group add': '스팟그룹 추가',

      // edit_utils_widget
      'PERIOD': '기간',
      'DATE': '날짜',
      'WEEK': '주간',
      'DAY OF WEEK': '요일',
      'TIME': '시간',


      // utils
      'Tag input': '태그 입력',
      'Please enter the address to search': '검색할 주소를 입력해주세요',
      'No results were found for your search': '검색 결과가 없습니다',
      'SELECT LOG': '선택 기록',
      '(Stored data will be completely deleted)': '(저장된 데이터가 완전히 삭제됩니다)',
      'Deselect': '선택해제',
      'CUSTOM FIELD SELECT': '',
      'Custom field': '사용자 정의 항목',
      'Back': '뒤로',
      'Please enter the title': '제목을 입력해 주세요',
      'RESERVE START DAY': '예약 개시일',
      'NUMBER OF RESERVATIONS': '예약 인원',
      'unlimited': '제한없슴',
      'Paste': '붙여넣기',
      'SPOT GROUP +': '스팟 그룹 +',
      'SPOT +': '스팟 +',
      'EVENT +': '이벤트 +',
      'CLASS +': '강습 +',
      'SPOT STORY +': '스팟 스토리 +',
      'EVENT STORY +': '이벤트 스토리 +',
      'URL LINK': '웹페이지 링크',
      'IMAGE EDIT': '이미지 편집',
      'DELETE': '삭제',
      'EDIT': '편집',
      'ENABLE': '활성화',
      'DISABLE': '비활성화',
      'REPORT': '신고',
      'PAYMENT OK': '입금 확인',
      'PAYMENT CANCEL': '입금 취소',
      'CONFIRM': '확인',
      'REJECT': '거절',
      'SEND MESSAGE': '메시지보내기',
      'FOLLOW CANCEL': '팔로우 취소',
      'BLOCK': '차단하기',
      'UNBLOCK': '차단해제',
      'VIEW REPORT': '신고내용보기',
      'REPORT RESULT': '신고결과보기',
      'REPORT CANCEL': '신고취소',
      'Comment +': '댓글 +',
      'Image size edit': '이미지 사이즈 설정',
      'Story edit': '스토리 편집',
      'Report type': '신고 종류',
      'Please write what you want to report': '신고 내용을 작성해 주세요',
      'Please add supporting documents': '본인이 소유자임을 증명하는 자료를 첨부해 주세요\n(사업자등록증 사본등)',
      'Report has been completed': '신고 처리가 완료되었습니다',
      'Follow+': 'Follow+',
      'Follow*': 'Follow*',
      'Follow1': 'Follower',
      'Follow2': 'Follow',
      'Me': 'Me',
      'year': '년',
      'years': '년',
      'month': '개월',
      'months': '개월',
      'hour': '시간',
      'hours': '시간',
      'minute': '분',
      'minutes': '분',
      'sec': '초',
      'Already reported': '이미 신고가 완료되었습니다',
      'Create a new spot group': '새로운 스팟그룹을 추가합니다',
      'Duplicate groups can be merged with other groups later': '중복된 그룹일경우 추후에 다른 그룹과 합쳐질수 있습니다',
      'Create a new spot': '새로운 스팟을 추가합니다',
      'If you are not the actual owner of the spot, the owner may be forcibly changed later': '해당 스팟의 실제 소유자가 아닐경우, 추후 소유자가 강제변경 될 수 있습니다',
      'Create a new event': '새로운 이벤트를 추가합니다',
      'If you are not the actual owner of the event, the owner may be forcibly changed later': '해당 이벤트의 실제 소유자가 아닐경우, 추후 소유자가 강제변경 될 수 있습니다',


      // main_top
      'COUNTRY SELECT': '지역 선택',

      // widget
      'You can add banners': '베너를 추가할 수 있습니다',
      'You can add images': '이미지를 추가 할 수 있습니다',
      'This is a secret...': '비밀글 입니다...',
      'REPLY': '답글',
      'Edit/Del': '편집/삭제',
      'ANSWER': '답변',
      'QnA': 'QnA',
      'ADD': '추가',
      'Vote': '추천',
      'January': '1월',
      'February': '2월',
      'March': '3월',
      'April': '4월',
      'May': '5월',
      'June': '6월',
      'July': '7월',
      'August': '8월',
      'September': '9월',
      'October': '10월',
      'November': '11월',
      'December': '12월',
      'Representative images cannot be deleted': '대표이미지는 삭제할 수 없습니다',
      'Theme select': '테마 선택',
      'LIGHT': '라이트',
      'DARK': '다크',
      'The format of the phone number provided is incorrect': '잘못된 형식의 전화번호입니다',
      'Auth credential is invalid': '잘못된 인증번호입니다',


      // dialog
      'uploading now...': '업로드 중입니다...',
      'processing now...': '처리 중입니다...',
      'updating now...': '업데이트 중입니다...',
      'image downloading...': '이미지 다운로드 중입니다...',
      'Are you sure you want to delete it?': '삭제하시겠습니까?',
      'Are you sure you want to cancel it?': '취소하시겠습니까?',
      'Are you sure you want to quit the app?': '앱을 종료 하시겠습니까?',
      'Are you sure you want to quit the Sign Up?': '회원가입을 종료 하시겠습니까?',
      'copied to clipboard': '클립보드에 복사되었습니다',
      'Update is complete': '업데이트가 완료되었습니다',
      'Deleted': '삭제 되었습니다',
      'Spot group select': '스팟 그룹 선택',
      'Group select': '그룹 선택',
      'Typing \'delete now\'': '\'지금 삭제\'를 입력해 주세요',
      'delete now': '지금 삭제',
      'Alert) Recovery is not possible': '주의) 삭제후에는 복구가 불가능합니다',
      'Are you sure you want to undo the modifications?': '수정된 내용을 취소 하시겠습니까?',
      'Banner image select': '배너이미지 선택',
      'Banner': '베너',
      'Do you want to upload?': '업로드 하시겠습니까?',
      'Upload is complete': '업로드가 완료됬습니다',
      'SAVE': '저장하기',
      'User error': '유저 오류',
      'Delete confirm': '삭제 확인',
      'Delete has been completed': '삭제가 완료되었습니다',
      'Delete has been failed': '삭제에 실패했습니다',
      'Update has been completed': '수정이 완료되었습니다',
      'Processing is complete': '처리 완료되었습니다',
      'Download complete': '다운로드가 완료되었습니다',
      'Would you like to send a report?': '레포트를 전송하시겠습니까?',
      'Welcome to KSpot': 'KSpot에 오신것을 환영합니다',
      'Sign up completed': '회원가입이 완료되었습니다',
      'Can not find target': '대상을 찾을 수 없습니다',
      'Select': '선택',
      'Added': '추가됨',
      'Don\'t see again': '다시 안보기',
      'Go to market': '마켓으로 이동',

      // category group
      'Sports / Fitness': '스포츠 / 피트니스',
      'Language / Literature': '어학 / 문학',
      'Finance / Investment': '재테크 / 투자',
      'Cooking / Beverage': '요리 / 음료',
      'Concert / Exhibition': '콘서트 / 전시',
      'Computer / Game': '컴퓨터 / 게임',
      'Music / Instrument': '음악 / 악기',
      'Photo / Video': '사진 / 영상',
      'Fashion / Beauty': '패션 / 뷰티',
      'Craft / DIY': '공예 / DIY',
      'Art / Design': '미술 / 디자인',
      'Coding / Programming': '코딩 / 프로그래밍',
      'Dance / Performance': '댄스 / 공연',
      'Etc': '기타',

      // dialog button
      'Delete': '삭제',
      'Cancel': '취소',
      'OK': '확인',
      'APP EXIT': '앱 종료',
      'Exit': '종료',
      'Done': '완료',
      'Add': '추가',
      'add': '추가',
      'Upload': '업로드',
      'Update': '수정',

      // button
      'SHARE': '공유',
      'COMMENT+': '댓글+',
      'TALK': '대화',
      'EVENT ADD': '이벤트 추가',
      'CLASS ADD': '강습 추가',
      'SPOT\nSTORY ADD': '스팟\n스토리 추가',
      'EVENT\nSTORY ADD': '이벤트\n스토리 추가',
      'PORTFOLIO ADD': '포트폴리오 추가',

      // error
      'Unable to get data': '정보를 가져올 수 없습니다',
      'Data does not exist': '정보가 존재하지 않습니다',
      'User data does not exist': '유저정보가 존재하지 않습니다',
      'Can not find user information': '해당 유저정보를 찾을 수 없습니다',
      'Upload failed': '업로드가 실패했습니다',
      'No date information': '날짜 정보가 없습니다',
      'List does not exist': '목록이 존재하지 않습니다',
    }
  };
}
