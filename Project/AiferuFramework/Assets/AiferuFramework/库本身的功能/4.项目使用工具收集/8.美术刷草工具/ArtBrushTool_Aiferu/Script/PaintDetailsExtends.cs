#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace AiferuFramework.ArtBrushTool
{
    [InitializeOnLoad]
    public class PaintDetailsEXtends
    {
        private static int layerMask =0;
        #region 绑定场景GUI渲染回调
        static PaintDetailsEXtends()
        {
            //绑定场景GUI渲染回调
            SceneView.duringSceneGui += OnSceneGUI;
        }

        ~PaintDetailsEXtends()
        {
            SceneView.duringSceneGui -= OnSceneGUI;
        }
        #endregion

        //Scene面板回调函数
        static void OnSceneGUI(SceneView view)
        {
            //判断是否开启了美术刷草工具
            if (ArtBrushToolEW.Enable)
            {
                Debug.Log("我还在我还在");
                Planting();
            }
        }


        static void Planting()
        {
            //使用射线取地面交点
            Event e = Event.current;
            //当鼠标左键点击时
            RaycastHit raycastHit = new RaycastHit();
            Ray terrainRay = HandleUtility.GUIPointToWorldRay(e.mousePosition);
            Debug.DrawLine(terrainRay.origin, terrainRay.GetPoint(100), Color.red);
            //绘制笔刷
            
            if (Physics.Raycast(terrainRay, out raycastHit, Mathf.Infinity))
            {
                //绘制笔刷
                    
                //根据鼠标划过位置和编辑器面板设置的密度等参数实例化植被 并打上标记
            }
            DrawBrush(raycastHit);
        }
        /// <summary>
        /// 绘制笔刷
        /// </summary>
        private static void DrawBrush(RaycastHit hit)
        {
            if (ArtBrushToolEW.BrushEnable)
            {
                //设置编辑模式为无,这样刷笔刷的时候就无法使用移动旋转等
                Tools.current = Tool.None;
                //禁用默认的选择,这样就不会选中物体
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

                //绘制笔刷样式
                Handles.color = Color.white;
                Handles.DrawSolidDisc(hit.point, hit.normal, 1);
                Handles.color = Color.black;
                Handles.DrawWireDisc(hit.point, hit.normal, 2);
                Handles.DrawWireDisc(hit.point, hit.normal, 3);
                Debug.Log("在画了在画了");
            }

        }
    }
}
#endif
