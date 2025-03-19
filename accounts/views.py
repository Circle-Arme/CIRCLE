from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model

User = get_user_model()  # استخدام النموذج المخصص

# توليد JWT Token عند تسجيل الدخول
@api_view(['POST'])
def login_api(request):
    email = request.data.get('email')  # استخدم email بدلاً من username
    password = request.data.get('password')

    user = authenticate(email=email, password=password)  # تأكد من المصادقة الصحيحة
    if user is not None:
        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })
    return Response({'error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'}, status=400)

# إنشاء حساب جديد
@api_view(['POST'])
def register_api(request):
    email = request.data.get('email')  # استخدم email
    password = request.data.get('password')
    first_name = request.data.get('first_name', '')
    last_name = request.data.get('last_name', '')

    if User.objects.filter(email=email).exists():
        return Response({'error': 'البريد الإلكتروني مأخوذ بالفعل'}, status=400)

    user = User.objects.create_user(email=email, password=password, first_name=first_name, last_name=last_name)
    return Response({'message': 'تم إنشاء الحساب بنجاح!'}, status=201)

# اختبار المصادقة
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({'message': f'مرحبًا {request.user.email}, هذه صفحة محمية!'})  # استخدام email بدلاً من username
