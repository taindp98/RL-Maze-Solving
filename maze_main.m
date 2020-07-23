clear all
%------------------------GENERATE MAZE SIZE 6*6----------------------------
%PARAMETER
n = 6;

%INITIAL M MATRIX IS MAZE
M = ones(6,6);

%INITIAL EDGES OF MAZE
M(2,1:2) = -100;
M(2,5) = -100;
M(3,5) = -100;
M(4,1) = -100;
M(4,4) = -100;
M(5,6) = -100;
M(6,4) = -100;

%GENERATE R MATRIX REWARD IS ZEROS
R = zeros(n*n,n*n);

%GENERATE VALUES FOR REWARD MATRIX 
for i=1:n*n
    for j=1:n*n
        % ONLY ONE STEP FOR EACH SLOT
    if j~=i-n  && j~=i+n  && j~=i-1 && j~=i+1
        R(i,j)=-1;
    end
        % AT EDGES OF MAZE
    if j==7 || j==8 || j==11 || j==17 || j==19 || j==22 || j==34 || j==30
        R(i,j)=-1;
    end
        %MUST MOVE FOR EACH SLOT
    if i==j
        R(i,j)=-1;
    end
        % AT EDGES OF MAZE
    if i==7 || i==8 || i==11 || i==17 || i==19 || i==22 || i==34 || i==30
        R(i,j)=-1;
    end
    end
end

%FIND VALUES POSSIBLE REACH GOAL STATE
find_goal = find(R(:,n*n)==0);

%ASSIGN VALUES AT GOAL STATE 100
R(find_goal,n*n) = 100;
R(n*n,n*n)=100;

%-------------------------------TRAINING-----------------------------------
%ASSIGN VALUES GOAL STATE
goal_state=n*n; %36

%GAMMA VALUE
gamma=0.8;

%EPISODE TRAINING
epi=20;

%GENERATE Q MATRIX TRAINING IS ZEROS SIZE 36x36
Q=zeros(n*n,n*n);


for i=1:epi
    
    %RANDOM CURRENT STATE
    cur_state=1;   
    while(1)
        %FIND ACTION POSSIBLE
        action= find(R(cur_state,:)>=0);
        
        %SELECT NEXT STATE
        next_state = action(randi([1 length(action)],1,1));
        
        %SELECT ACTION POSSIBLE FOR NEXT STATE
        action = find(R(next_state,:)>=0);
        
        %INITIAL Q VALUES
        Q_max = 0;
        
        %FIND Q MAX VALUES
        for j=1:length(action)
            Q_max = max(Q_max,Q(next_state,action(j)));
        end
        
        %UPDATE Q VALUES
        Q(cur_state,next_state)=R(cur_state,next_state)+gamma*Q_max;
        
        %CHECK CURRENT STATE WITH GOAL STATE
        if(cur_state == goal_state)
            break;
        end
        
    %UPDATE CURRENT STATE    
    cur_state=next_state;
    end
end

%-------------------------------SOLVING MAZE-------------------------------
%ASSUME START STATE
cur_test=1;

%ASSIGN LOCATION START ON PATH
x(1)=cur_test;
t=1;

%FIND PATH USING Q MATRIX
if cur_test~=goal_state
    while(1)
    t=t+1;
    f=find(Q(cur_test,:)==max(Q(cur_test,:)));
    x(t)=f(randi([1 length(f)],1,1));
    cur_test=x(t);
    if cur_test==goal_state
        break;
    end
    end
end

%SIMULATE SOLVING MAZE
S=M;

for i=1:length(x) 
        c=mod(x(i),n);
        if c~=0
            r=floor(x(i)/n)+1;
            S(r,c)=-20;
        else
            r=floor(x(i)/n);
            S(r,c+6)=-20;
        end
end

subplot(2,1,1);
imagesc(M);
text(1,1,'START','HorizontalAlignment','right')
text(n,n,'GOAL','HorizontalAlignment','right')
subplot(2,1,2);
imagesc(S);
colormap(winter);
text(1,1,'START','HorizontalAlignment','right')
text(n,n,'GOAL','HorizontalAlignment','right')



