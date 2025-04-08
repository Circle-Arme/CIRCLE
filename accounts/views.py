from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model

User = get_user_model()
#تقريبا هنا غيرت انو يستخدم الايميل ما بتذكر بالضبط بس شاتو غير لي شس
# ✅ تسجيل الدخول باستخدام البريد الإلكتروني
@api_view(['POST'])
def login_api(request):
    email = request.data.get('email')
    password = request.data.get('password')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({'error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'}, status=400)

    if not user.check_password(password):
        return Response({'error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'}, status=400)

    refresh = RefreshToken.for_user(user)
    return Response({
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    })


# ✅ إنشاء حساب جديد
@api_view(['POST'])
def register_api(request):
    email = request.data.get('email')
    password = request.data.get('password')
    first_name = request.data.get('first_name', '')
    last_name = request.data.get('last_name', '')

    if User.objects.filter(email=email).exists():
        return Response({'error': 'البريد الإلكتروني مأخوذ بالفعل'}, status=400)

    user = User.objects.create_user(
        email=email,
        password=password,
        first_name=first_name,
        last_name=last_name
    )

    return Response({'message': 'تم إنشاء الحساب بنجاح!'}, status=201)


# ✅ صفحة محمية (للاختبار)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({'message': f'مرحبًا {request.user.email}, هذه صفحة محمية!'})
