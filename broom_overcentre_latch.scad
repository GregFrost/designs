
broom_d=19;
layer_height=0.31;
extruded_width=0.5;
screw_d=4.5;

x=48;
hinge_d=3;
t=extruded_width*4;
$fn=64;
epsilon=0.01;
final_angle=78;
hinge_height=22;
h_clearance=1;
v_clearance=layer_height*1;
spacing=3;

A=[0,broom_d/2+t+hinge_d/2];
B=(broom_d/2+t*2+hinge_d/2)*[sin(x),cos(x)];
B2=[B[0]+hinge_d/2+t,B[1]];
C=[B2[0],A[1]-t];
D=[C[0]+t+hinge_d/2,C[1]];
E=[D[0]+t+hinge_d/2,D[1]];
F=[E[0],broom_d/2*0.6];
F2=[F[0]+hinge_d/2,F[1]];
G=[broom_d/2+t+hinge_d/2,0];

I=F2+(2*t+spacing)*[1,1];
J=[I[0],A[1]+hinge_d/2+t+spacing+t];

K=(broom_d/2+t)*[cos(final_angle),-sin(final_angle)];

*%translate(K)
cylinder(h=100,d=1);

module arc(r1=1,r2=2,angle=45)
{
	difference()
	{
		intersection()
		{
			circle(r=r2);
			translate([-r2*3/2,0])
			square(3*r2);
			rotate(angle-180)
			translate([-r2*3/2,0])
			square(3*r2);
		}
		circle(r=r1);
	}
}

module hinge1()
{
	translate(A) 
	circle(d=hinge_d);
	
	rotate(90-x)
	arc(r1=broom_d/2+t,r2=broom_d/2+t+epsilon,angle=x);
}

module hinge2()
{
	translate(B)
	rotate(-x-90)
	arc(r1=t+hinge_d/2,r2=t+hinge_d/2+epsilon,angle=90+x);

	translate(B2)
	square([epsilon,C[1]-B2[1]]);

	translate(D)
	arc(r1=t+hinge_d/2,r2=t+hinge_d/2+epsilon,angle=180);
}

module hinge3()
{
	translate(F)
	square([epsilon,E[1]-F[1]]);

	hull()
	{
		translate(F+[hinge_d/2,0])
		circle(d=hinge_d);
	
		translate(G)
		circle(d=hinge_d);
	}

	rotate(-final_angle)
	arc(r1=broom_d/2+t,r2=broom_d/2+t+epsilon,angle=final_angle);
}

module hinge()
{
    difference ()
    {
        z=3;
    
        union()
        {
            offset(r=-z)
            offset(r=t+z)
            hinge1();
            
            offset(r=t)
            hinge2();
    
            offset(r=-z)
            offset(r=t+z)
            hinge3();
        }
        translate(A)
        circle(d=hinge_d);
        translate(F2)
        circle(d=hinge_d);
    }
}

module hinge_clearance()
{
    offset(r=h_clearance)
    hinge();

    translate(F2)
    rotate(90)
    translate(-F2)
    offset(r=h_clearance)
    hinge();
}

module hinge_cone()
{
    cylinder(d1=hinge_d+2*t-2.1*extruded_width,d2=0,h=hinge_d+2*t-2.1*extruded_width);
}

module right_hinge()
{
    difference()
    {
        linear_extrude(height=hinge_height,convexity=4)
        hinge();
 
        translate([0,0,hinge_height/4-v_clearance/2])
        linear_extrude(height=hinge_height/2+v_clearance,convexity=4)
        union()
        {
            mount_clearance();
            translate(A)
            circle(d=hinge_d+2*t+2*h_clearance,h=hinge_height/4+v_clearance/2+1);
        }

        translate([0,0,hinge_height*3/4+v_clearance/2-epsilon])
        translate(A)
        hinge_cone();
        
        translate([0,0,hinge_height*3/4+v_clearance/2-epsilon])
        translate(F2)
        hinge_cone();
    }
}

module left_hinge()
{
    mirror([1,0,0])
    difference()
    {
        linear_extrude(height=hinge_height,convexity=4)
        hinge();
 
        for (z=[-1,hinge_height*3/4-v_clearance/2])
        translate([0,0,z])
        linear_extrude(height=hinge_height/4+v_clearance/2+1,convexity=4)
        union()
        {
            mount_clearance();
            translate(A)
            circle(d=hinge_d+2*t+2*h_clearance,h=hinge_height/4+v_clearance/2+1);
        }
        
        translate([0,0,hinge_height/4+v_clearance/2-epsilon])
        translate(F2)
        hinge_cone();

        translate([0,0,hinge_height/4+v_clearance/2-epsilon])
        translate(A)
        hinge_cone();
    }
}

*right_hinge();
*left_hinge();

module mount1()
{
    translate(F2)
    circle(d=hinge_d+2*t);
}
module mount2()
{
    translate(I)
    circle(d=hinge_d+2*t);
}
module mount3()
{
    translate(J+[0,-t/2])
    square([hinge_d+2*t,t],center=true);
}
module mount4()
{
    translate([0,J[1]-t])
    square([hinge_d+2*t,t]);
}

module half_mount()
{
    hull()
    {
        mount1();
        mount2();
    }
    
    hull()
    {
        mount2();
        mount3();
    }
    
    hull()
    {
        mount3();
        mount4();
    }
}

module mount_profile()
{
    half_mount();
    mirror([1,0,0])
    half_mount();
}

module mount_outline()
{
    difference()
    {
        mount_profile();
        offset(r=-0.5)
        mount_profile();
    }
}

*mount_outline();

module mount_clearance()
{
    offset(r=h_clearance)
    mount_profile();

    translate(F2)
    rotate(-90)
    translate(-F2)
    offset(r=h_clearance)
    mount_profile();
}

*mount_clearance();

module mount_holes()
{
    // Mounting holes.
    for (z=[1,3]*hinge_height/4)
    for (x=[1,-1]*J[0]*1/2)
    translate([x,J[1],z])
    rotate([90,0,0])
    translate([0,0,-t/2])
    rotate(180/8)
    cylinder(h=2*t,d=screw_d,$fn=8);
}

module mount(assembled=false)
{ 
    difference()
    {
        linear_extrude(height=hinge_height,convexity=4)
        mount_profile();
        
        mirror([1,0,0])
        translate([0,0,hinge_height/4-v_clearance/2])
        linear_extrude(height=hinge_height/2+v_clearance,convexity=4)
        hinge_clearance();
        
        translate([0,0,-1])
        linear_extrude(height=hinge_height/4+v_clearance/2+1,convexity=4)
        hinge_clearance();

        translate([0,0,hinge_height-hinge_height/4-v_clearance/2])
        linear_extrude(height=hinge_height/4+v_clearance/2+1,convexity=4)
        hinge_clearance();
        
        translate(F2)
        translate([0,0,-1])
        cylinder(d=hinge_d,h=hinge_height+2);

        mirror([1,0,0])
        translate(F2)
        translate([0,0,-1])
        cylinder(d=hinge_d,h=hinge_height+2);


        translate([0,0,hinge_height/4+v_clearance/2-epsilon])
        translate(F2)
        hinge_cone();
        
        mirror([1,0,0])
        translate([0,0,hinge_height*3/4+v_clearance/2-epsilon])
        translate(F2)
        hinge_cone();

        mount_holes();
    }
}

module assembled()
{
    left_hinge();
    right_hinge();
    
    mount(assembled=true);

    // The broom handle.
    translate([0,0,-hinge_height/2])
    %cylinder(d=broom_d,h=hinge_height*2);

    // Warp prevention.    
    hull()
    {
        translate(K)
        cylinder(d=10,h=layer_height);
        mirror([1,0,0])
        translate(K)
        cylinder(d=10,h=layer_height);
    }
    
    translate(J+[6,0])
    cylinder(d=16,h=layer_height);

    mirror([1,0,0])
    translate(J+[6,0])
    cylinder(d=16,h=layer_height);
}

rotate(-90)
{
    assembled();
}
