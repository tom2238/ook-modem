% *
% * Copyright (C) 2018 Tomas Dubina <t.dubina at volny dot cz>
% *
% * This program is free software; you can redistribute it and/or modify
% * it under the terms of the GNU General Public License as published by
% * the Free Software Foundation; either version 2 of the License, or
% * any later version.
% *
% * This program is distributed in the hope that it will be useful,
% * but WITHOUT ANY WARRANTY; without even the implied warranty of
% * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% * GNU Library General Public License for more details.
% *
% * You should have received a copy of the GNU General Public License
% * along with this program; if not, write to the Free Software
% * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
% 
% Matlab OOK Modulator/Demodulator
% Author: Tomas Dubina, 203552
% BPC2E Matlab project, VUT FEKT 2018
function [ui] = ook_gui()
   clear
   % okna a prvky 
   ui.figure = figure('Name','OOK Modulator/Demodulator','NumberTitle','off','Position',[300,300,900,480],'resize','off');  
   ui.rate.popupmenu = uicontrol('style','popupmenu','unit','pix','Position',[220 450 200 16],'string',{'200','400','600','800','1000','1200','2400','3200','4800','6000','7200','9600'},'callback',@SetRate,'value',6);  
   ui.rate.text  = uicontrol('Style','text','String','Rychlost prenosu [Bd]: ','Position',[10 447 200 16]);
   ui.carrier.popupmenu = uicontrol('style','popupmenu','unit','pix','Position',[220 420 200 16],'string',{'400','600','800','1200','1600','2000','2400','3600','4200','4800','7200','8000','9000','9600'},'callback',@SetCarrier,'value',7);  
   ui.carrier.text = uicontrol('Style','text','String','Nosny kmitocet [Hz]: ','Position',[10,417,200,16]);
   ui.noise.slider = uicontrol('Style', 'slider','Min',1,'Max',120,'Value',1,'unit', 'pix','Position', [220 387 200 16],'Callback', @SetNoise,'SliderStep', [1/100 1/10]);
   ui.noise.text = uicontrol('Style','text','String','Uroven sumu: ','Position',[10,387,200,16]);
   ui.noise.value = uicontrol('Style','text','String','3 %','Position',[430,387,100,16]);
   ui.noise.valuediv = uicontrol('Style','text','String','1/27.1126','Position',[530,387,100,16]);
   ui.lowpass.slider = uicontrol('Style', 'slider','Min',4,'Max',24,'Value',12,'unit', 'pix','Position', [220 357 200 16],'Callback', @SetLowpass,'SliderStep', [1/20 1/10]);
   ui.lowpass.text = uicontrol('Style','text','String','Rad IQ filtru: ','Position',[10,357,200,16]);
   ui.lowpass.value = uicontrol('Style','text','String','16','Position',[430,357,100,16]);  
   ui.file.sourceedit = uicontrol('Style','edit','Units','pix','Position',[220,330,200,20], 'CallBack',@SetSourceFile,'String','data.bin');
   ui.file.sourcetext = uicontrol('Style','text','String','Nazev vstupniho souboru: ','Position',[10,330,200,16]);
   ui.text.sourcefilesize = uicontrol('Style','text','String','Delka: 0 [B]','Position',[430,330,200,16]);
   ui.file.destinationedit = uicontrol('Style','edit','Units','pix','Position',[220,300,200,20], 'CallBack',@SetDestinationFile,'String','data_out.bin');
   ui.file.destinationtext = uicontrol('Style','text','String','Nazev vystupniho souboru: ','Position',[10,300,200,16]);  
   ui.file.isimage = uicontrol('Style','checkbox', 'Value',0,'Units','pix','Position',[430,300,20,16],'callback',@IsSourceImage);
   ui.text.isimage = uicontrol('Style','Text','String','Vstupem je obrazek','Units','pix','Position',[450,300,180,16]);
   ui.file.datainedit = uicontrol('Style','edit','Units','pix','Position',[220,270,200,20], 'CallBack',@SetOutputDataWaveFile,'String','input_data.wav');
   ui.file.dataintext = uicontrol('Style','text','String','Vystupni datovy WAV: ','Position',[10,270,200,16]);  
   ui.file.customiis = uicontrol('Style','checkbox', 'Value',0,'Units','pix','Position',[430,270,20,16],'callback',@SetImageResolution);
   ui.file.customix = uicontrol('Style','edit','Units','pix','Position',[500,270,60,20], 'CallBack',@SetImageX,'String','64');
   ui.file.customiy = uicontrol('Style','edit','Units','pix','Position',[570,270,60,20], 'CallBack',@SetImageY,'String','64');
   ui.text.customimage = uicontrol('Style','text','String','Rozl:','Position',[450,270,45,16]); 
   ui.file.transedit = uicontrol('Style','edit','Units','pix','Position',[220,240,200,20], 'CallBack',@SetOutputTransWaveFile,'String','output_transmit.wav');
   ui.file.transtext = uicontrol('Style','text','String','Vys|Vs-tupni modulovany WAV: ','Position',[10,240,200,16]);
   ui.file.transwavonly = uicontrol('Style','checkbox', 'Value',0,'Units','pix','Position',[430,240,20,16],'callback',@SetDemoWavOnly);
   ui.text.transwavonly = uicontrol('Style','Text','String','Pouze demodulovat z WAV','Units','pix','Position',[450,240,180,16]);
   ui.file.demoedit = uicontrol('Style','edit','Units','pix','Position',[220,210,200,20], 'CallBack',@SetOutputDemoTransWaveFile,'String','output_demodulated.wav');
   ui.file.demotext = uicontrol('Style','text','String','Vystupni demodulovany WAV: ','Position',[10,210,200,16]); 
   ui.file.dataoutedit = uicontrol('Style','edit','Units','pix','Position',[220,180,200,20], 'CallBack',@SetOutputDemoDataWaveFile,'String','output_data.wav');
   ui.file.dataouttext = uicontrol('Style','text','String','Vystupni data z WAV: ','Position',[10,180,200,16]);
   ui.text.datadecoded = uicontrol('Style','text','String','Dekodovana data: ','Position',[10,150,200,16]);
   ui.text.datadecodedrate = uicontrol('Style','text','String','Rychlost: 0 [Bd]','Position',[220,150,200,16]);
   ui.text.datadecodedlen = uicontrol('Style','text','String','Delka: 0 [B]','Position',[430,150,200,16]);
   ui.text.status1 = uicontrol('Style','text','String','Status','Position',[10,100,620,16]);
   ui.text.status2 = uicontrol('Style','text','String','Status','Position',[10,80,620,16]);
   ui.text.status3 = uicontrol('Style','text','String','Status','Position',[10,60,620,16]);
   ui.button.reset = uicontrol('Style','pushbutton','String','Reset','Position',[20,20,80,25],'callback',@Reset);
   ui.button.code1 = uicontrol('Style','pushbutton','String','Koder','Position',[110,20,80,25],'callback',@Code1);
   ui.button.code2 = uicontrol('Style','pushbutton','String','Modulace','Enable','off','Position',[200,20,80,25],'callback',@Code2);
   ui.button.code3 = uicontrol('Style','pushbutton','String','Demodulace','Enable','off','Position',[290,20,80,25],'callback',@Code3);
   ui.button.code4 = uicontrol('Style','pushbutton','String','Dekoder','Enable','off','Position',[380,20,80,25],'callback',@Code4);
   ui.button.exit = uicontrol('Style','pushbutton','String','Konec','Position',[470,20,80,25],'callback',@Exit); 
   % vychozi nastaveni
   ui.settings.rate = 1200;
   ui.settings.carrier = 2400;
   ui.settings.fs = 48000;
   ui.settings.headrate = 200;
   ui.settings.noise = 27.1126;
   ui.settings.filter = 16;
   ui.settings.bittresh = 0.4;
   ui.settings.sourcefile = 'data.bin';
   ui.settings.destinationfile = 'data_out.bin';
   ui.settings.isimage = 0;
   ui.settings.datain = 'input_data.wav';
   ui.settings.trans = 'output_transmit.wav';
   ui.settings.demoonly = 0;
   ui.settings.demo = 'output_demodulated.wav';
   ui.settings.dataout = 'output_data.wav';
   ui.settings.msgcount = 0;
   ui.settings.image = [0 0 0];
   ui.settings.imageres = [64 64 3];
   ui.settings.imageresval = 0;
   % promena data
   ui.work.data = 0;
   ui.work.trate = 0;
   ui.work.transmit = 0;
   ui.work.tr_y = 0;
   ui.work.audiow = 0;
   ui.work.decodedrate = 0;
   ui.work.decodedlen = 0;
   ui.axes.source = axes('Units','Pixels','Position',[660,260,200,200]); 
   ui.axes.destination = axes('Units','Pixels','Position',[660,30,200,200]); 
   %axis off;
   % Make the UI visible.
   ui.figure.Visible = 'on';
   
   
  function [] = SetRate(object,~) % rychlost prenosu
    str = get(object,'String');
    val = get(object,'Value');
    ui.settings.rate=str2double(str(val));
    disp(['Notice: Transmission speed, ' num2str(ui.settings.rate)]);  
    if ui.settings.rate > ui.settings.carrier
      disp('Warning: Transmission speed is higher then carrier frequency');
      set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
      set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
      set(ui.text.status1, 'String',strcat('Pozor: Prenosova rychlost je vyssi nez nosny kmitocet!',' [',num2str(ui.settings.msgcount),']̈́'));  
      ui.settings.msgcount = ui.settings.msgcount + 1;
    end 
  end

  function [] = SetCarrier(object,~) % nosny kmitocet
    str = get(object,'String');
    val = get(object,'Value');
    ui.settings.carrier=str2double(str(val));
    disp(['Notice: Carrier frequency, ' num2str(ui.settings.carrier)]); 
    if ui.settings.rate > ui.settings.carrier
      disp('Warning: Carrier frequency is lower then transmission speed'); 
      set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
      set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
      set(ui.text.status1, 'String',strcat('Pozor: Nosny kmitocet je nizsi nez prenosova rychlost!',' [',num2str(ui.settings.msgcount),']̈́')); 
      ui.settings.msgcount = ui.settings.msgcount + 1;
    end 
  end

  function [] = SetNoise(object,~) % uroven sumu se nastavuje logaritmicky
    percent = get(object, 'Value');
    percent = round(percent);  
    ui.settings.noise = exp((100-percent)/30);
    set(object, 'Value', percent);
    set(ui.noise.value, 'String', [num2str(ceil(100-(100/27.1126*ui.settings.noise))+3) ' %']);   
    set(ui.noise.valuediv,'String',strcat('1/',num2str(ui.settings.noise)));
    disp(['Notice: Noise slider position value, ' num2str(percent)]);   
    disp(['Notice: Noise divider, ' num2str(ui.settings.noise)]); 
  end

  function [] = SetLowpass(object,~) % rad dolno-propustniho IQ filtru
    order = get(object, 'Value');
    order = round(order);  
    ui.settings.filter = order;
    set(object, 'Value', order);
    set(ui.lowpass.value, 'String', num2str(order));   
    disp(['Notice: Lowpass filter order, ' num2str(order)]);   
  end

  function [] = SetSourceFile(object,~) % nazev vstupniho souboru  
    ui.settings.sourcefile = get(object, 'String');
    disp(['Notice: Source file, ' ui.settings.sourcefile]); 
    if ui.settings.demoonly == 0
      if exist(ui.settings.sourcefile, 'file') ~= 2
          disp(['Error: Source file not found, ' ui.settings.sourcefile]);
          set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
          set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
          set(ui.text.status1, 'String',strcat('Chyba: Vstupni soubor nenalezen!',' [',num2str(ui.settings.msgcount),']̈́'));
          ui.settings.msgcount = ui.settings.msgcount + 1;
          set(ui.button.code1,'Enable','off');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      else
          set(ui.button.code1,'Enable','on');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      end
    end
  end

  function [] = SetDestinationFile(object,~) % nazev vystupniho souboru
    ui.settings.destinationfile = get(object, 'String');
    disp(['Notice: Destination file, ' ui.settings.destinationfile]); 
    %if exist(ui.settings.destinationfile, 'file') ~= 2
    %  disp(['E: Destination file not found, ' ui.settings.destinationfile]); 
    %end    
  end

  function [] = IsSourceImage(object,~) % Vstupem dat je obrazek
    ui.settings.isimage = get(object, 'Value');
    disp(['Notice: Source data is image, ' num2str(ui.settings.isimage)]); 
%     if ui.settings.isimage == 1
% 
%           
%     else
%       
%     end    
  end

  function [] = SetOutputDataWaveFile(object,~) % nazev vstupnich dat v WAV
    ui.settings.datain = get(object, 'String');
    disp(['Notice: Output coded data wav file, ' ui.settings.datain]);    
  end

  function [] = SetOutputTransWaveFile(object,~) % nazev vystupnich modulovanych dat v WAV
    ui.settings.trans = get(object, 'String');
    disp(['Notice: Output modulated data wav file, ' ui.settings.trans]);   
    if ui.settings.demoonly == 1
      if exist(ui.settings.trans, 'file') ~= 2
        disp(['Error: Input transmitted file not found, ' ui.settings.trans]); 
        set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
        set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
        set(ui.text.status1, 'String',strcat('Chyba: Vstupni WAV soubor pro demodulaci nenalezen!',' [',num2str(ui.settings.msgcount),']̈́')); 
        ui.settings.msgcount = ui.settings.msgcount + 1;
        set(ui.button.code1,'Enable','off');
        set(ui.button.code2,'Enable','off');
        set(ui.button.code3,'Enable','off');
        set(ui.button.code4,'Enable','off'); 
      else
        set(ui.button.code1,'Enable','off');
        set(ui.button.code2,'Enable','off');
        set(ui.button.code3,'Enable','on');
        set(ui.button.code4,'Enable','off'); 
      end    
    else
      if exist(ui.settings.sourcefile, 'file') ~= 2
          disp(['Error: Source file not found, ' ui.settings.sourcefile]);
          set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
          set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
          set(ui.text.status1, 'String',strcat('Chyba: Vstupni soubor nenalezen!',' [',num2str(ui.settings.msgcount),']̈́'));
          ui.settings.msgcount = ui.settings.msgcount + 1;
          set(ui.button.code1,'Enable','off');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      else
          set(ui.button.code1,'Enable','on');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      end 
    end
  end

  function [] = SetDemoWavOnly(object,~) % Nekodovat , pouze demodulovat, dekodovat
    ui.settings.demoonly = get(object, 'Value');
    disp(['Notice: Only demodulate, decode, ' num2str(ui.settings.demoonly)]); 
    if ui.settings.demoonly == 1
      if exist(ui.settings.trans, 'file') ~= 2
        disp(['Error: Input transmitted file not found, ' ui.settings.trans]);  
        set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
        set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
        set(ui.text.status1, 'String',strcat('Chyba: Vstupni WAV soubor pro demodulaci nenalezen!',' [',num2str(ui.settings.msgcount),']̈́')); 
        ui.settings.msgcount = ui.settings.msgcount + 1;
        set(ui.button.code1,'Enable','off');
        set(ui.button.code2,'Enable','off');
        set(ui.button.code3,'Enable','off');
        set(ui.button.code4,'Enable','off'); 
      else
        set(ui.button.code1,'Enable','off');
        set(ui.button.code2,'Enable','off');
        set(ui.button.code3,'Enable','on');
        set(ui.button.code4,'Enable','off'); 
      end    
    else
      if exist(ui.settings.sourcefile, 'file') ~= 2
          disp(['Error: Source file not found, ' ui.settings.sourcefile]);
          set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
          set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
          set(ui.text.status1, 'String',strcat('Chyba: Vstupni soubor nenalezen!',' [',num2str(ui.settings.msgcount),']̈́'));
          ui.settings.msgcount = ui.settings.msgcount + 1;
          set(ui.button.code1,'Enable','off');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      else
          set(ui.button.code1,'Enable','on');
          set(ui.button.code2,'Enable','off');
          set(ui.button.code3,'Enable','off');
          set(ui.button.code4,'Enable','off');
      end 
    end    
  end

  function [] = SetOutputDemoTransWaveFile(object,~) % nazev vystupnich demodulovanych dat v WAV
    ui.settings.demo = get(object, 'String');
    disp(['Notice: Output demodulated data wav file, ' ui.settings.demo]);    
  end

  function [] = SetImageResolution(object,~) % nastav rozliseni na manual
    ui.settings.imageresval = get(object, 'Value');
    disp(['Notice: Custom image resolution in decoder, ' num2str(ui.settings.imageresval)]);    
  end

  function [] = SetImageX(object,~) % nastav rozliseni X
    res_d = uint32(str2double(get(object, 'String')));
    if res_d == 0
       disp('Error: Custom image resolution X is not number or zero or less then zero'); 
       set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
       set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
       set(ui.text.status1, 'String',strcat('Chyba: Rozliseni osy X neni cele kladne cislo!',' [',num2str(ui.settings.msgcount),']̈́'));
       ui.settings.msgcount = ui.settings.msgcount + 1;
       set(ui.file.customiis, 'Value',0);
    else    
       ui.settings.imageres(1) = res_d;
       disp(['Notice: Custom image resolution X, ' num2str(ui.settings.imageres(1))]); 
    end    
  end

  function [] = SetImageY(object,~) % nastav rozliseni Y
    res_d = uint32(str2double(get(object, 'String')));
    if res_d == 0
       disp('Error: Custom image resolution Y is not number or zero or less then zero'); 
       set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
       set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
       set(ui.text.status1, 'String',strcat('Chyba: Rozliseni osy Y neni cele kladne cislo!',' [',num2str(ui.settings.msgcount),']̈́'));
       ui.settings.msgcount = ui.settings.msgcount + 1;
       set(ui.file.customiis, 'Value',0);
    else    
       ui.settings.imageres(2) = res_d;
       disp(['Notice: Custom image resolution Y, ' num2str(ui.settings.imageres(2))]); 
    end       
  end

  function [] = SetOutputDemoDataWaveFile(object,~) % nazev vystupnich dat v WAV
    ui.settings.dataout = get(object, 'String');
    disp(['Notice: Output decoded data wav file, ' ui.settings.dataout]);    
  end

  function [] = Code1(~, ~) % zakodovat do wav
     tic();
     if ui.settings.isimage == 1
        dat=imread(ui.settings.sourcefile); 
        image(dat,'Parent',ui.axes.source);
        [image_X, image_Y, image_Z]=size(dat);
        dat=dat(:);
        file_size=image_X*image_Y*image_Z;
        ui.settings.image = [image_X image_Y image_Z];
        set(ui.text.sourcefilesize, 'String', ['Delka: ' num2str(file_size) ' [B]']);
     else
       fd_rb = fopen(ui.settings.sourcefile,'rb');
       file_size = dir(ui.settings.sourcefile);
       file_size = file_size.bytes;
       set(ui.text.sourcefilesize, 'String', ['Delka: ' num2str(file_size) ' [B]']);
       dat=fread(fd_rb,file_size,'ubit8');
       fclose(fd_rb);
     end    
        
     fs=ui.settings.fs;
     rate=ui.settings.rate;
     head_rate=ui.settings.headrate;
     head_slower=rate/head_rate;
     head_s = linspace(0,0,(3+2+3)*8); % in 64 bits  slow speed
     head_s(1:24)=[0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];  %calibration 24bits
     head_e = linspace(0,0,8); % in 8 bits  normal speed
     %rate 16bits
     cc=uint16(rate);
     for ik = 1:1:16
         y = bitget(cc,ik);
         if y == 1
             head_s(ik+25-1)=1;
         else
             head_s(ik+25-1)=0;
         end
     end
     %data length 24bits
     cc=uint32(file_size);
     for ik = 1:1:24
         y = bitget(cc,ik);
         if y == 1
             head_s(ik+41-1)=1;
         else
             head_s(ik+41-1)=0;
         end
     end
     
     [~, head_s_y] = size(head_s);
     [~, head_e_y] = size(head_e);
     bit_len=8*(file_size+head_s_y/8*head_slower+head_e_y/8);
     bit_time=1/rate;
     
     trate = 0 : bit_time*bit_len*fs-1;
     
     [~,tr_y]=size(trate);
     one_bit=tr_y/bit_len;
     
     data = linspace(0,0,uint32((file_size+head_s_y/8*head_slower+head_e_y/8)*8*one_bit));
     %data = [];
     data_pointer=1;
     %start header + rate + data_length
     warning off;
     for  ic = 1:1:uint32(head_s_y)
         y = head_s(ic);
         if y == 1
             data(data_pointer:data_pointer+one_bit*head_slower-1)=1;
         else
             data(data_pointer:data_pointer+one_bit*head_slower-1)=0;
         end
         data_pointer = data_pointer + one_bit*head_slower;
         
     end
     %data
     for  ic = 1:1:uint32(file_size)
         cc=uint8(dat(ic));
         for ik = 1:1:8
             y = bitget(cc,ik);
             if y == 1
                 data(data_pointer:data_pointer+one_bit-1)=1;
             else
                 data(data_pointer:data_pointer+one_bit-1)=0;
             end
             data_pointer = data_pointer + one_bit;
         end
     end
     %end header, zeros
     for  ic = 1:1:uint32(head_e_y)
         y = head_e(ic);
         if y == 1
             data(data_pointer:data_pointer+one_bit-1)=1;
         else
             data(data_pointer:data_pointer+one_bit-1)=0;
         end
         data_pointer = data_pointer + one_bit;     
     end
     warning on;
     wavwrite(data,ui.settings.fs,16,ui.settings.datain);
     ui.work.data = data;
     ui.work.trate = trate;
     ui.work.tr_y = tr_y;
     disp(['Notice: Coded and saved in ' num2str(toc())]); 
     set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
     set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
     set(ui.text.status1, 'String',strcat('Koder: Hotovo. Zpracovano za',{' '},num2str(toc()),' s',' [',num2str(ui.settings.msgcount),']̈́')); 
     ui.settings.msgcount = ui.settings.msgcount + 1;
     set(ui.button.code2,'Enable','on');
     set(ui.button.code3,'Enable','off');
     set(ui.button.code4,'Enable','off');
  end

  function [] = Code2(~, ~) % modulovat do wav
     tic();
     carrier=sin(2*pi*(ui.settings.carrier/ui.settings.fs)*ui.work.trate);
     transmit = carrier.*ui.work.data;  
     noise = (rand(ui.work.tr_y,1)-0.5)/ui.settings.noise;
     transmit=transmit+noise';
     transmit=transmit/max(abs(transmit));
     wavwrite(transmit,ui.settings.fs,16,ui.settings.trans);
     ui.work.transmit = transmit;
     disp(['Notice: Modulated and saved in ' num2str(toc())]); 
     set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
     set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
     set(ui.text.status1, 'String',strcat('Modulator: Hotovo. Zpracovano za',{' '},num2str(toc()),' s',' [',num2str(ui.settings.msgcount),']̈́')); 
     ui.settings.msgcount = ui.settings.msgcount + 1;
     set(ui.button.code3,'Enable','on');
     set(ui.button.code4,'Enable','off');
  end

  function [] = Code3(~, ~) % demodulovat z wav
     tic();
     if ui.settings.demoonly == 1
       [transmit,fs,bits] = wavread(ui.settings.trans);
       ui.work.transmit=transmit';
       ui.settings.fs=fs;
       [~, efs_y]=size(ui.work.transmit);   
       ui.work.trate = 0 : efs_y-1;
       Is=cos(2*pi*((ui.settings.fs/4)/ui.settings.fs)*ui.work.trate+(2*pi/3));
       Qs=-sin(2*pi*((ui.settings.fs/4)/ui.settings.fs)*ui.work.trate+(2*pi/3));  
       Ia=Is.*ui.work.transmit;
       Qa=Qs.*ui.work.transmit; 
     else
       Is=cos(2*pi*((ui.settings.fs/4)/ui.settings.fs)*ui.work.trate+(2*pi/3));
       Qs=-sin(2*pi*((ui.settings.fs/4)/ui.settings.fs)*ui.work.trate+(2*pi/3));   
       Ia=Is.*ui.work.transmit;
       Qa=Qs.*ui.work.transmit; 
       bits=16;
     end    
     [filter_b, filter_a] = butter(ui.settings.filter,0.5,'low');
     Ia = filter(filter_b, filter_a, Ia);
     Qa = filter(filter_b, filter_a, Qa);
     Ia=Ia/max(abs(Ia));
     Qa=Qa/max(abs(Qa)); 
     audiow = sqrt(Ia.*Ia+Qa.*Qa)-0.5;
     audiow = audiow/max(audiow);
     % testing /*
     [filter_b, filter_a] = butter(12,2200/ui.settings.fs,'low');
     audiow(1:ui.settings.fs*0.32-1) = filter(filter_b, filter_a, audiow(1:ui.settings.fs*0.32-1)); % 0.32 sec header
     audiow(1:ui.settings.fs*0.32-1) = audiow(1:ui.settings.fs*0.32-1) + 0.25;
     audiow(1:250) = -0.3; 
     audiow(1:ui.settings.fs*0.32-1) = audiow(1:ui.settings.fs*0.32-1)/max(audiow(1:ui.settings.fs*0.32-1)); 
     audiow(ui.settings.fs*0.32:end) = audiow(ui.settings.fs*0.32-52:end-52); %phase shift
     %figure  54
     %freqz(filter_b,filter_a);
     %delay = mean(grpdelay(firf))
     % */ testing
     wavwrite(audiow,ui.settings.fs,bits,ui.settings.demo);
     ui.work.audiow = audiow;
     disp(['Notice: Demodulated and saved in ' num2str(toc())]);
     set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
     set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
     set(ui.text.status1, 'String',strcat('Demodulator: Hotovo. Zpracovano za',{' '},num2str(toc()),' s',' [',num2str(ui.settings.msgcount),']̈́')); 
     ui.settings.msgcount = ui.settings.msgcount + 1;
     set(ui.button.code4,'Enable','on');
  end
  
  function [] = Code4(~, ~) % dekodovat z wav
     tic();
     data_out=linspace(-1,-1,uint32(ui.work.tr_y)); 
     for it = 1:1:ui.work.tr_y
         if ui.work.audiow(it)<-0.1
             data_out(it)=-1;
         else
             data_out(it)=1;
         end
     end
     wavwrite(data_out,ui.settings.fs,16,ui.settings.dataout);     
     head_l_bits = 0;
     head_l_bit_c = 1;
     head_z_bits = 0;
     head_z_bit_c = 1;
     head_detect = 0;
     head_proc_ok = 0;
     head_zero_ok = 0;
     if ui.work.tr_y < ui.settings.fs*0.5
         head_location = ui.work.tr_y;
     else
         head_location = ui.settings.fs*0.5;
     end
     for ip = 1:1:head_location
         if data_out(ip) == 1
             if head_detect == 0
                 head_detect = 1;
                 head_start_dec = ip;
             end
         end
         if head_detect == 1 && head_proc_ok == 0
             if data_out(ip) == 1
                 head_l_bits = head_l_bits + 1;
             else
                 head_l_bits = head_l_bits + 0;
             end
             if head_l_bit_c == ui.settings.fs*(8/ui.settings.headrate)
                 head_l_ok=head_l_bits/(ui.settings.fs*(8/ui.settings.headrate));
                 %head_l_ok
                 %head_l_bits
                 if head_l_ok > 0.8
                     head_proc_ok = 1;
                     ip = ip + 1;
                 end
             end
             head_l_bit_c = head_l_bit_c + 1;
         end
         if head_proc_ok == 1 && head_zero_ok == 0
             if data_out(ip) == 1
                 head_z_bits = head_z_bits + 1;
             else
                 head_z_bits = head_z_bits + 0;
             end
             if head_z_bit_c == ui.settings.fs*(8/ui.settings.headrate)
                 head_z_ok=head_z_bits/(ui.settings.fs*(8/ui.settings.headrate));
                 if head_z_ok < 0.1
                     head_zero_ok = 1;
                     head_start_dec = head_start_dec + 2*ui.settings.fs*(8/ui.settings.headrate);
                 end
             end
             head_z_bit_c = head_z_bit_c + 1;
         end
     end
     % dekoder rychlosti prenosu
     bit_decode = 0;
     data_pointer=0;
     one_bit = ui.settings.fs/ui.settings.headrate;
     cc = uint16(0);
     bit_position = 1;
     decoded_ok = 0;
     for ip = head_start_dec:1:head_location
         if decoded_ok == 0
             if data_out(ip) == 1
                 bit_decode = bit_decode + 1;
             else
                 bit_decode = bit_decode + 0;
             end
             data_pointer = data_pointer + 1;
             if  data_pointer==one_bit
                 bit_value = bit_decode/one_bit ;
                 if bit_value > ui.settings.bittresh
                     cc=bitset(uint16(cc), bit_position, 1);
                 else
                     cc=bitset(uint16(cc), bit_position, 0);
                 end
                 bit_position = bit_position + 1;
                 bit_decode = 0;
                 data_pointer = 0;
             end
             if bit_position > 16
                 rate_decoded = cc;
                 decoded_ok = 1;
                 head_start_dec = head_start_dec + 2*ui.settings.fs*(8/ui.settings.headrate);
             end
         end
     end
     % dekoder poctu dat v souboru
     bit_decode = 0;
     data_pointer=0;
     one_bit = ui.settings.fs/ui.settings.headrate;
     cc = uint32(0);
     bit_position = 1;
     decoded_ok = 0;
     for ip = head_start_dec:1:head_location
         if decoded_ok == 0
             if data_out(ip) == 1
                 bit_decode = bit_decode + 1;
             else
                 bit_decode = bit_decode + 0;
             end
             data_pointer = data_pointer + 1;
             if  data_pointer==one_bit
                 bit_value = bit_decode/one_bit ;
                 if bit_value > ui.settings.bittresh
                     cc=bitset(uint32(cc), bit_position, 1);
                 else
                     cc=bitset(uint32(cc), bit_position, 0);
                 end
                 bit_position = bit_position + 1;
                 bit_decode = 0;
                 data_pointer = 0;
             end
             if bit_position > 24
                 data_len_decode = cc;
                 decoded_ok = 1;
                 data_start = head_start_dec + 3*ui.settings.fs*(8/ui.settings.headrate);
                 %rate_decoded
                 data_end = uint32(data_len_decode*8*ui.settings.fs/uint32(rate_decoded)+uint32(data_start));
                 if data_end > ui.work.tr_y
                     data_end = ui.work.tr_y;
                 end
             end
         end
     end
     
     
     if ui.settings.isimage == 1
       imagedata = uint8(linspace(0,0,data_len_decode));
     else
       fd_rb = fopen(ui.settings.destinationfile,'wb');
     end  
     one_bit = ui.settings.fs/rate_decoded;
     ui.work.decodedrate = rate_decoded;
     ui.work.decodedlen = data_len_decode;
     if ui.work.decodedlen > 11120
       disp('Bug: Decoded data corrupted. > 11120 bytes');
     end    
     set(ui.text.datadecodedrate, 'String', ['Rychlost: ' num2str(ui.work.decodedrate) ' [Bd]']);  
     set(ui.text.datadecodedlen, 'String', ['Delka: ' num2str(ui.work.decodedlen) ' [B]']); 
     bit_decode = double(0);
     data_pointer=0;
     cc = uint8(0);
     bit_position = 1;
     image_cur_byte = 1;
     %cc_out=linspace(0,0,12);
     %cc_out=uint8(cc_out);
     % !!! testing /*
     %[filter_b, filter_a] = butter(12,2200/ui.settings.fs,'low');
     %audiow(ui.settings.fs*0.32:end) = filter(filter_b, filter_a, audiow(ui.settings.fs*0.32:end)); 
     %audiow(ui.settings.fs*0.32:end) = audiow(ui.settings.fs*0.32:end) + 0.25;
     %audiow(ui.settings.fs*0.32:end) = audiow(ui.settings.fs*0.32:end)/max(audiow(ui.settings.fs*0.32:end));
     % !!! testing */
     % nekde je bug, nelze dekodovat vice nez 11120 bajtu, Linux x86 r2012a 
     %disp('Decoded len?');
     %one_bit
     %disp((data_end-data_start)/8/uint32(one_bit));
     for it = data_start:1:data_end
         if data_out(it) == 1
             bit_decode = bit_decode + 1;
         else
             bit_decode = bit_decode + 0;
         end
         data_pointer = data_pointer + 1;
         if  data_pointer==one_bit
             bit_value = bit_decode/double(one_bit);
             if bit_value > ui.settings.bittresh
                 cc=bitset(uint8(cc), bit_position, 1);
             else
                 cc=bitset(uint8(cc), bit_position, 0);
             end
             bit_position = bit_position + 1;
             bit_decode = 0;
             data_pointer = 0;
         end
         if bit_position > 8
             if ui.settings.isimage == 1
               imagedata(image_cur_byte) = uint8(cc);
               image_cur_byte = image_cur_byte + 1;
             else    
               fwrite(fd_rb,uint8(cc),'ubit8');
             end
             bit_decode = 0;
             cc = uint8(0);
             bit_position = 1;
         end     
     end
     % konec bugu?!
     if ui.settings.isimage == 1
        if  ui.settings.imageresval == 1
          image_decoded = reshape(imagedata, ui.settings.imageres);
        else  
          image_decoded = reshape(imagedata, ui.settings.image);
        end  
        image(image_decoded,'Parent',ui.axes.destination);
        imwrite(image_decoded,ui.settings.destinationfile,'bmp');
     else    
       fclose(fd_rb);
     end   
     disp(['Notice: Decoded data and saved in ' num2str(toc())]);
     set(ui.text.status3, 'String',get(ui.text.status2, 'String'));
     set(ui.text.status2, 'String',get(ui.text.status1, 'String'));
     set(ui.text.status1, 'String',strcat('Dekoder: Hotovo. Zpracovano za',{' '},num2str(toc()),' s',' [',num2str(ui.settings.msgcount),']̈́')); 
     ui.settings.msgcount = ui.settings.msgcount + 1;   
  end

  function [] = Reset(~, ~)
     ui.settings.rate = 1200;
     ui.settings.carrier = 2400;
     ui.settings.fs = 48000;
     ui.settings.headrate = 200;
     ui.settings.noise = 27.1126;
     ui.settings.filter = 12;
     ui.settings.sourcefile = 'data.bin';
     ui.settings.destinationfile = 'data_out.bin';
     ui.settings.datain = 'input_data.wav';
     ui.settings.isimage = 0;
     ui.settings.trans = 'output_transmit.wav';
     ui.settings.demoonly = 0;
     ui.settings.demo = 'output_demodulated.wav';
     ui.settings.dataout = 'output_data.wav';
     ui.settings.msgcount = 0;
     ui.settings.image = [0 0 0];
     ui.settings.imageres = [64 64 3];
     ui.settings.imageresval = 0;
     ui.work.data = 0;
     ui.work.trate = 0;
     ui.work.transmit = 0;
     ui.work.tr_y = 0;
     ui.work.audiow = 0;
     ui.work.decodedrate = 0;
     ui.work.decodedlen = 0;
     set(ui.rate.popupmenu, 'Value', 6);
     set(ui.carrier.popupmenu, 'Value', 7);
     set(ui.noise.slider, 'Value', 1);
     set(ui.noise.value, 'String', [num2str(ceil(100-(100/27.1126*ui.settings.noise))+3) ' %']);
     set(ui.noise.valuediv,'String','1/27.1126');
     set(ui.lowpass.slider, 'Value', 12);
     set(ui.lowpass.value, 'String', num2str(16));
     set(ui.file.sourceedit, 'String',ui.settings.sourcefile); 
     set(ui.file.destinationedit, 'String',ui.settings.destinationfile); 
     set(ui.file.isimage, 'Value',0);
     set(ui.file.datainedit, 'String',ui.settings.datain);
     set(ui.file.customiis, 'Value',0);
     set(ui.file.customix, 'String','64');
     set(ui.file.customiy, 'String','64');
     set(ui.file.transedit, 'String',ui.settings.trans);
     set(ui.file.transwavonly, 'Value',0);
     set(ui.file.demoedit, 'String',ui.settings.demo);
     set(ui.file.dataoutedit, 'String',ui.settings.dataout);
     set(ui.text.datadecodedrate, 'String', 'Rychlost: 0 [Bd]');
     set(ui.text.datadecodedlen, 'String', 'Delka: 0 [B]');
     set(ui.text.sourcefilesize, 'String', 'Delka: 0 [B]');
     set(ui.text.status1, 'String','Status');
     set(ui.text.status2, 'String','Status');
     set(ui.text.status3, 'String','Status');
     cla(ui.axes.source,'reset');
     cla(ui.axes.destination,'reset');
     set(ui.button.code1,'Enable','on');
     set(ui.button.code2,'Enable','off');
     set(ui.button.code3,'Enable','off');
     set(ui.button.code4,'Enable','off');
     disp('Notice: Reseted '); 
  end 
  
  function [] = Exit(~, ~)
    disp('Notice: Exiting . . . ');  
    clear all;  
    close all force;   
  end 
end
