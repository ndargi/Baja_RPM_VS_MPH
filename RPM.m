classdef RPM <handle
    properties
        Figure
        Stop_Button
        Start_Button
        Status_Panel
        Sheet_Panel
        Sheet_string
        plot_region
        COM_Panel
        COM_Select
        csv_figure
        csv_string
        csv_button
        xlsx_selected
        xlsx_change_button
        
        begin
        initial
        csvfile
        COMS
        datamph
        datarpm
        sheetname
        totaldata
    end
    methods
        function app = RPM
            app.datamph = [];
            app.datarpm = [];
            app.COMS = {'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8'};
        app.Figure = figure('units','normalized',...
                'position',[.3 .3 .4 .5],...
                'Name','BU Baja Car Tracker',...
                'NumberTitle','off',...
                'CloseRequestFcn',@app.closeApp);
           app.Stop_Button = uicontrol(app.Figure,...
                    'style','pushbutton',...
                    'units','normalized',...
                    'position',[0.1 0.1 0.15 0.08], ...
                    'string','Stop',...
                    'callback',@app.Stop,...
                    'backgroundcolor',[1 0 0]);
                
           app.Start_Button = uicontrol(app.Figure,...
                    'style','pushbutton',...
                    'units','normalized',...
                    'position',[0.3 0.1 0.15 0.08], ...
                    'string','Start',...
                    'callback', @app.pick_csv,...
                    'backgroundcolor',[0 1 0]);
                
                
       app.Status_Panel = uicontrol(app.Figure,...
                    'style','text',...
                    'units','normalized',...
                    'position',[0.6 0.08 0.15 0.08], ...
                    'string','Stopped',...
                    'HorizontalAlignment','center',...
                    'Fontsize',12); 
                
      app.Sheet_Panel = uipanel(app.Figure,...
                    'units','normalized',...
                    'position',[0.15 0.21 0.25 0.1],...
                    'Title','Sheet');
                
                
     app.Sheet_string = uicontrol(app.Sheet_Panel,...
                    'style','edit',...
                    'units','normalized',...
                    'position',[.05 .2 .9 .6]);
                
     app.plot_region =  axes('Parent',app.Figure,...
                'units','normalized',...
                'position',[.10 .38 .8 .6]);
     app.xlsx_selected = uicontrol(app.Figure,...
                    'style','text',...
                    'units','normalized',...
                    'position',[0.6 0.02 0.2 0.05], ...
                    'string','No xlsx selected',...
                    'HorizontalAlignment','center',...
                    'Fontsize',12);       
     app.COM_Panel = uipanel(app.Figure,...
                    'units','normalized',...
                    'position',[0.55 0.21 0.25 0.1],...
                    'Title','COM Select');
     app.COM_Select = uicontrol(app.COM_Panel,...
                    'units','normalized',...
                    'position',[.05 .02 .9 .9],...
                    'style','popupmenu',...
                    'string',app.COMS);
      app.xlsx_change_button = uicontrol(app.Figure,...
                    'style','pushbutton',...
                    'units','normalized',...
                    'position',[0.35 0.02 0.2 0.04], ...
                    'string','Change Xlsx',...
                    'callback',@app.pick_csv);       
                app.initial = true;    
        end
        function pick_csv(app,varargin)
            set(app.Start_Button,'callback',@app.go)
             app.csv_figure = figure('units','normalized',...
                    'position',[.4 .475 .2 .05],...
                    'Name','xlsx Choice',...
                    'NumberTitle','off',...
                    'CloseRequestFcn',@app.closeApp2);
                
            app.csv_string = uicontrol(app.csv_figure,...
                    'units','normalized',...
                    'position',[.05 .1 .6 .9],...
                    'style','edit',...
                    'string','Enter xlsx filename here');
            app.csv_button = uicontrol(app.csv_figure,...
                    'units','normalized',...
                    'position',[.7 .1 .3 .9],...
                    'style','pushbutton',...
                    'string','Set_Filename',...
                    'callback',@app.set_csv);
   
        end
        function go(app,varargin)
            app.sheetname = get(app.Sheet_string,'string');
            app.begin = false;
            set(app.Status_Panel,'string','Running');
            try
            s = serial(app.COMS{get(app.COM_Select,'Value')});
            fopen(s);
            catch
                set(app.Status_Panel,'string','No Connection');
                return
                
            end
            pause(.5);
            run = true;
            
            while (run==true) %Inside will run until stop is pressed
                out = fscanf(s);
                [first,last] = strtok(out,':');
                if first == 'M'
                    try
                      if firsttimeinM == 1
                        firsttimeinM = 2;
                    else
                        stop(timer1)
                      end
                    end

                    [mph,~] = strtok(last,':');
                    mph = str2double(mph);
                    app.datamph(1+length(app.datamph)) = mph ;
                elseif first == 'R'
                    try
                        if firsttimeinR == 1
                        firsttimeinR = 2;
                        else
                        stop(timer2)
                        end
                    end
                    [rpm,~] = strtok(last,':');
                    rpm = str2double(rpm);                   
                    app.datarpm(1+length(app.datarpm)) = rpm;
                                                         
                end
                
                pause(.01)
                if app.begin == true;
                    run = false;
                end
              
            end
            
        end
        function set_csv(app,varargin)
            app.csvfile = get(app.csv_string,'string');
            app.csvfile = sprintf('%s.xlsx',app.csvfile);
            set(app.xlsx_selected,'string',app.csvfile);
        end
        function Stop(app,varargin)       
          
            X = linspace(1,length(app.datarpm),length(app.datarpm));
            Y = linspace(1,length(app.datamph),length(app.datamph));
            app.begin = true;
            set(app.Status_Panel,'string','Stopped')
            pause(.2)
            plotyy(X,app.datarpm,Y,app.datamph)
            if length(app.datamph)>length(app.datarpm)
                app.datarpm(length(app.datarpm)+1:length(app.datamph)) = 0
            else
                app.datamph(length(app.datamph)+1:length(app.datarpm)) = 0
            end
            app.totaldata = [app.datamph;app.datarpm];
             xlswrite(app.csvfile,app.totaldata,app.sheetname);
        end
        function closeApp(app,hObjectm,eventdata)
            delete(app.Figure)

        end
         function closeApp2(app,hObjectm,eventdata)
            delete(app.csv_figure)
            app.initial = false;
        end
    end
end
    
    