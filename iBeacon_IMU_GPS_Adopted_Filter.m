%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����ʼ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;

iBeacon_IMU_location = ParticleFilter();
GPS_IMU_location = GPS_IMU_PF();
Adopted_location = zeros(2,361);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȫ�ֱ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outdoor_sensor_data=361;
indoor_sensor_data=0;
sensor_data=outdoor_sensor_data+indoor_sensor_data;
d=0.1;%��׼��
Theta=CreateGauss(0,d,1,sensor_data);%GPS������DR�����ļн�
ZOUT=zeros(4,outdoor_sensor_data);
ZIN=zeros(4,indoor_sensor_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fgps=fopen('sensor_data_041518.txt','r');%%%���ı�

for n=1:sensor_data
    gpsline=fgetl(fgps);%%%��ȡ�ı�ָ���Ӧ����
    if ~ischar(gpsline) break;%%%�ж��Ƿ����
    end;
    %%%%��ȡ��������
   time=sscanf(gpsline,'[Info] 2016-04-15%s(ViewController.m:%d)-[ViewController outputAccelertion:]:lat:%f;lon:%f;heading:%f;distance:%f;beacon_lat:%f;beacon_lon:%f');
   data=sscanf(gpsline,'[Info] 2016-04-15 %*s (ViewController.m:%*d)-[ViewController outputAccelertion:]:lat:%f;lon:%f;heading:%f;distance:%f;beacon_lat:%f;beacon_lon:%f');
   if(isempty(data))
       break;
   end
        result=lonLat2Mercator(data(6,1),data(5,1));
        gx(n)=result.X;%GPS��������任��Ķ������꣬���������
        gy(n)=result.Y;%GPS��������任��ı������꣬���������
        Phi(n)=(data(3,1)+90)*pi/180;%�����
        dd(n)=data(4,1);%ĳһ���ڵ�λ��
        ZIN(:,n)=[gx(n),gy(n),Phi(n),dd(n)];
        if ZIN(1,n) == 0
            Adopted_location(1,n) = GPS_IMU_location(1,n);
            Adopted_location(2,n) = GPS_IMU_location(2,n);
        else
            Adopted_location(1,n) = iBeacon_IMU_location(1,n);
            Adopted_location(2,n) = iBeacon_IMU_location(2,n);
        end
end
fclose(fgps);%%%%%�ر��ļ�ָ��

cordinatex=round(ZIN(1,5));
cordinatey=round(ZIN(2,5));

[groundtruthx,groundtruthy]=Groud_Truth();
groundtruth = [groundtruthx,groundtruthy]';
iBeacon_IMU_location_line=iBeacon_IMU_location(:,2:361)-groundtruth(:,2:361);
iBeacon_IMU_location_error=sqrt(iBeacon_IMU_location_line(1,:).^2+iBeacon_IMU_location_line(2,:).^2);
GPS_IMU_location_line=GPS_IMU_location(:,2:361)-groundtruth(:,2:361);
GPS_IMU_location_error=sqrt(GPS_IMU_location_line(1,:).^2+GPS_IMU_location_line(2,:).^2);
Adopted_location_line=Adopted_location(:,2:361)-groundtruth(:,2:361);
Adopted_location_error=sqrt(Adopted_location_line(1,:).^2+Adopted_location_line(2,:).^2);

x_Adopted_location = zeros(1,11);
c_Adopted_location = zeros(1,11);
[b_Adopted_location, x_Adopted_location(1,2:11)]=hist(Adopted_location_error,10);
num=numel(Adopted_location_error);
%figure;plot(x_Adopted_location(1,2:11),b_Adopted_location/num);   %�����ܶ�
c_Adopted_location(1,2:11)=cumsum(b_Adopted_location/num);        %�ۻ��ֲ�

x_iBeacon_IMU_location = zeros(1,11);
c_iBeacon_IMU_location = zeros(1,11);
[b_iBeacon_IMU_location, x_iBeacon_IMU_location(1,2:11)]=hist(iBeacon_IMU_location_error,10);
num=numel(iBeacon_IMU_location_error);
%figure;plot(x_Adopted_location(1,2:11),b_Adopted_location/num);   %�����ܶ�
c_iBeacon_IMU_location(1,2:11)=cumsum(b_iBeacon_IMU_location/num);        %�ۻ��ֲ�

x_GPS_IMU_location = zeros(1,11);
c_GPS_IMU_location = zeros(1,11);
[b_GPS_IMU_location, x_GPS_IMU_location(1,2:11)]=hist(GPS_IMU_location_error,10);
num=numel(GPS_IMU_location_error);
%figure;plot(x_Adopted_location(1,2:11),b_Adopted_location/num);   %�����ܶ�
c_GPS_IMU_location(1,2:11)=cumsum(b_GPS_IMU_location/num);        %�ۻ��ֲ�

figure;
plot(x_Adopted_location,c_Adopted_location,'r');hold on;
plot(x_iBeacon_IMU_location,c_iBeacon_IMU_location,'b');hold on;
plot(x_GPS_IMU_location,c_GPS_IMU_location,'g');hold off;
legend('iBeacon/IMU/GPS��λ', 'iBeacon/IMU��λ','GPS/IMU��λ');
xlabel('��λ���/m', 'FontSize', 10); ylabel('�ۻ����ʷֲ�/%', 'FontSize', 10);

figure(3);
set(gca,'FontSize',12);
plot(groundtruthx,groundtruthy,'r');hold on;
%plot( ZIN(1,:), ZIN(2,:), 'o');hold on;
plot(Adopted_location(1,:), Adopted_location(2,:), 'g');hold off;
axis([cordinatex-100 cordinatex+200 cordinatey-200 cordinatey+100]),grid on;
legend('��ʵ�켣', '�����˲��켣');
xlabel('x', 'FontSize', 20); ylabel('y', 'FontSize', 20);
axis equal;