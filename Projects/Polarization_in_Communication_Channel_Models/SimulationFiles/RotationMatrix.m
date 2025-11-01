function RotMat = RotationMatrix(varargin)
  % Input Arguments are: Roll, Pitch, Yaw
  roll = varargin{1};
  pitch = varargin{2};
  yaw = varargin{3};
  if nargin > 3
    if varargin{2} == "degree"
      alpha = yaw / 180 * pi;
      beta = pitch / 180 * pi;
      gamma = roll / 180 * pi;
    end
  else
    alpha = yaw;
    beta = pitch;
    gamma = roll;
  end
  RotMat = zeros(3,3);
  RotMat(1,1) = cos(alpha)*cos(beta);
  RotMat(1,2) = cos(alpha)*sin(beta)*sin(gamma)-sin(alpha)*cos(gamma);
  RotMat(1,3) = cos(alpha)*sin(beta)*cos(gamma)+sin(alpha)*sin(gamma);
  RotMat(2,1) = sin(alpha)*cos(beta);
  RotMat(2,2) = sin(alpha)*sin(beta)*sin(gamma)+cos(alpha)*cos(gamma);
  RotMat(2,3) = sin(alpha)*sin(beta)*cos(gamma)-cos(alpha)*sin(gamma);
  RotMat(3,1) = -sin(beta);
  RotMat(3,2) = cos(beta)*sin(gamma);
  RotMat(3,3) = cos(beta)*cos(gamma);
end
