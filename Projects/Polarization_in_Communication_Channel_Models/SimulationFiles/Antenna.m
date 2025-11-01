% Antenna Object
classdef Antenna < handle % One copy per instance only
  properties
    position = [0,0,0]; % [m], initial position at origin
    orientation = eye(3); % [roll, pitch, yaw], [phi, theta, psi], no rotation
    length = 0.05; % 5 cm length
    width = 0.05; % 5 cm width
    pattern;
  end
  
  methods
    function A = Antenna(position,orientation,patternFilename)
      A.position = position;
      A.orientation = orientation;
      A.pattern = Pattern(patternFilename);
    end
  
    function setPosition(A,x,y,z)
      A.position = [x,y,z];
    end
    
    function pos = getPosition(A)
      pos = A.position;
    end
        
    function setOrientation(A,phi,theta,psi)
      RotMat = RotationMatrix(phi,theta,psi); % Rotation matrix of the given angles
      A.orientation = RotMat;
    end
    
    function Rot = getOrientation(A)
      Rot = A.orientation;
    end
    
    function modOrientation(A,phi,theta,psi)
      RotMat = RotationMatrix(phi,theta,psi);
      A.orientation = RotMat * A.orientation;
    end
    
    
    function [patphi, pattheta] = getIncidentWave(A, Rot, phi, theta) % Calculates the antenna response for an incident angle phi and theta
      % Phi and theta given in antenna notation. Rot for rotation of uav.
      % Convert phi, theta angles to unitvector and apply rotation matrix

      % TODO: Set either earth or antenna coordinates!!
      theta = pi/2 - theta; % Calculate antenna to earth for rotation
      wavevec = zeros(1,3);
      wavevec(1) = cos(phi)*cos(theta);
      wavevec(2) = sin(phi)*cos(theta);
      wavevec(3) = sin(theta);
      
      outvec = Rot.' * A.orientation.' * wavevec.';
      patphi = atan2(outvec(2), outvec(1));
      pattheta = asin(outvec(3));
      pattheta = pi/2 - pattheta; % convert earth coordinates to sphere coordinates for pattern
    end
    
    function [Ephi, Ethe] = getFieldIncidentWave(A, Rot, phi, theta)
      % phi, theta incident angle, corresponding to antenna field vector
      % pattern works with degree, antenna with radiant, since the angular resolution is defined by degree, whereas rotations are calculated in radiant
      [phi,theta] = getIncidentWave(A,Rot,phi,theta);
      phi = phi / pi * 180;
      theta = theta / pi * 180;
      if theta > 180
        warning('theta too large\n')
      end
      [Ephi, Ethe] = A.pattern.getFieldOfAngle(phi,theta);
    end
    
    function rect = AntennaDrawObject(A) % return a rectangular object, which needs to be modified by channel and uav positions and rotations prior drawing
      rect = DrawRectangle(A.width,A.length);
      rect.setOrientation(A.orientation);
      rect.setPosition(A.position);
    end
    
    function DrawCoordinateSys(A,Rot,Pos)
      xvec = [1,0,0];
      yvec = [0,1,0];
      zvec = [0,0,1];
      start = [0,0,0];
      
      plane = [xvec;start;yvec;start;zvec].';
      iPos = [0,0,0];
      iPos = (Rot * A.position.').' + Pos;
      plane = Rot * A.orientation * plane;
      plane = plane + iPos.';
      
      % Draw all points in black
      hold on;
      plot3(plane(1,:),plane(2,:),plane(3,:), '-k');
      % Draw x in red
      plot3(plane(1,1:2),plane(2,1:2),plane(3,1:2),'-r');
    end
        
    function [dir,iPos] = AntennaDrawNormVector(A,Rot,Pos) % Returns normal vector of antenna.
      dir = [0,0,1];% init vector = z;
      dir = Rot * A.orientation * dir.';
      iPos = [0,0,0];
      iPos = (Rot * A.position.').' + Pos;
      quiver3(iPos(1),iPos(2),iPos(3),dir(1),dir(2),dir(3));
      hold on;
    end
    
    function v_draw = DrawUnitFieldComponent(A,component,Rot,Pos,phi,theta,colourcode,draw)
      if strncmp('theta', component,5)
        v = [0,1,0];
      elseif strncmp('r', component,5)
        v = [1,0,0];
      elseif strncmp('phi', component,5);
        v = [0,0,1];
      else
        error('component not known!');
      end
      
      S = transformationMatrix(phi,theta);
      v_cart = S * v.'; % Apply transformation
      %v_draw = Rot.' * v_cart; % Turn field in same direction as antenna.
      v_draw = Rot * A.orientation * v_cart;
      v_draw = A.orientation * v_cart;
      
      %v_draw = Rot * v_cart;
      
      %Draw vector
      if draw ~= 0
        quiver3(Pos(1), Pos(2), Pos(3), v_draw(1), v_draw(2), v_draw(3),colourcode);
      end;
    end
    
    function pattern = getAntennaPattern(A)
      pattern = A.pattern;
    end
    
    function alpha = calculateProjectionAngle(A, Rot, phi_k, theta_k)
      % phi and theta as angles of the wave vector of the wave towards the antenna, not the antenna incident angles.
      % alpha is returned in [rad]
      draw = 0; % Only calculation, no drawing.
      Pos = [0,0,0]; % drawing position
      
      E_vert = [0,1,0]; % e_r, e_theta, e_phi
      E_hor = [0,0,1];
      
      % Norm Wave Vec.
      % Calculate phi and theta component of outgoing antenna wave to calculate field vectors.
      k = zeros(1,3);
      k(1) = cos(phi_k)*sin(theta_k);
      k(2) = sin(phi_k)*sin(theta_k);
      k(3) = cos(theta_k);
      
      k_ant = -k;
      k_ant = Rot.' * A.orientation.' * k_ant.'; % Apply rotation of antenna in opposite direction to get field
      
      phi_ant = atan2(k_ant(2),k_ant(1));
      theta_ant = acos(k_ant(3));
      % calculate vertical and horzontal component of incident wave
      S = transformationMatrix(phi_k,theta_k);
      E_v = S * E_vert.';
      E_h = S * E_hor.';
      
      Etheta = A.DrawUnitFieldComponent('theta',Rot,Pos,phi_ant,theta_ant,'--b',draw);
      Ephi = A.DrawUnitFieldComponent('phi',Rot,Pos,phi_ant,theta_ant,'--k',draw);
      
      % Calculate angles of incident field from antenna perspective
      angver = acos(Etheta.' * E_v / (norm(Etheta)*norm(E_v)));
      anghor = acos(Etheta.' * E_h / (norm(Etheta)*norm(E_h)));
      if anghor < pi/2 % Use horizontal component as a measure of angular halfspace
        angver = 2 * pi - angver ;
      end
      alpha = angver;
    end
    
  end
end
