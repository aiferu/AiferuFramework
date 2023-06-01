#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using static UnityEditor.ShaderGraph.Internal.KeywordDependentCollection;
using static UnityEngine.Experimental.TerrainAPI.TerrainUtility;

namespace AiferuFramework.ArtBrushTool
{
    [InitializeOnLoad]
    public class PaintDetailsEXtends
    {
        private static int layerMask =0;
        #region 绑定场景GUI渲染回调
        static PaintDetailsEXtends()
        {
            //绑定场景GUI渲染回
            SceneView.duringSceneGui += OnSceneGUI;
        }

        //~PaintDetailsEXtends()
        //{
        //    SceneView.duringSceneGui -= OnSceneGUI;
        //}
        #endregion

        //Scene面板回调函数
        static void OnSceneGUI(SceneView view)
        {
            if (ArtBrushToolEW.ins == null)
                return;
            //判断是否开启了美术刷草工具
            if (ArtBrushToolEW.ins.Enable)
            {
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
            //Debug.DrawLine(terrainRay.origin, terrainRay.GetPoint(100), Color.red);
            if (Physics.Raycast(terrainRay, out raycastHit, Mathf.Infinity))
            {
                //根据鼠标划过位置和编辑器面板设置的密度等参数实例化植被 并打上标记
                //实例化植被
                if (e.type == EventType.MouseDown && e.button == 0 && ArtBrushToolEW.ins.BrushEnable)
                {
                    if (ArtBrushToolEW.ins.data.BrushIsAddMode)
                    {
                        //添加模式
                        AddBrush(raycastHit);
                    }else
                    {
                        //删除模式
                        SubBrush(raycastHit);
                    }

                }
            }
            //绘制笔刷
            DrawBrush(raycastHit);
        }

        /// <summary>
        /// 删除笔刷
        /// </summary>
        private static void SubBrush(RaycastHit hit)
        {
            //区域射线
            for (int i = 0; i < ArtBrushToolEW.ins.data.Density * ArtBrushToolEW.ins.data.BrushSize; i++)
            {
                Vector2 randomPoint = UnityEngine.Random.insideUnitCircle * (ArtBrushToolEW.ins.data.BrushSize / 2);
                Vector3 randomPoint3 = new Vector3(randomPoint.x, 0, randomPoint.y) + hit.point;
                Ray ray = new Ray(randomPoint3, hit.normal);
                Handles.DrawLine(randomPoint3, randomPoint3 + (hit.normal * ArtBrushToolEW.ins.data.BrushSize / 2));
                Debug.Log(randomPoint3);
            }
        }

        /// <summary>
        /// 添加笔刷
        /// </summary>
        private static void AddBrush(RaycastHit hit)
        {
            //区域射线
            for (int i = 0; i < ArtBrushToolEW.ins.data.Density * ArtBrushToolEW.ins.data.BrushSize; i++)
            {
                //计算射线坐标
                Vector2 randomPoint = UnityEngine.Random.insideUnitCircle * (ArtBrushToolEW.ins.data.BrushSize / 2);
                Vector3 randomPoint3 = new Vector3(randomPoint.x, 0, randomPoint.y);

                //绕法向量旋转坐标
                //计算法向量与世界y轴的旋转
                Quaternion rotation = Quaternion.FromToRotation(Vector3.up,hit.normal);
                Vector3 newPos = rotation* randomPoint3+hit.point;

                Ray ray = new Ray(newPos + hit.normal*Mathf.Clamp(ArtBrushToolEW.ins.data.BrushSize/36,0.1f,10f), -hit.normal);

                RaycastHit targetHit = new RaycastHit();

                Physics.Raycast(ray, out targetHit, Mathf.Infinity);
                Debug.DrawRay(ray.origin, ray.direction, Color.blue, 1f);
                Debug.Log(randomPoint3);
                Debug.Log(targetHit.point);
                InsProfab(targetHit);
            }

            
        }

        private static void InsProfab(RaycastHit hit)
        {
            GameObject target = ArtBrushToolEW.ins.data.Plants[ArtBrushToolEW.ins.data.PlantSelect];
            if (target == null) return;
            GameObject go = PrefabUtility.InstantiatePrefab(target) as GameObject;
            go.transform.position = hit.point;
            go.transform.up = hit.normal;
            float scale = UnityEngine.Random.Range(ArtBrushToolEW.ins.data.ScaleRandomMin, ArtBrushToolEW.ins.data.ScaleRandomMax);
            go.transform.localScale = go.transform.localScale * scale;
        }

        /// <summary>
        /// 绘制笔刷
        /// </summary>
        private static void DrawBrush(RaycastHit hit)
        {
            if (ArtBrushToolEW.ins.BrushEnable)
            {
                //设置编辑模式为无,这样刷笔刷的时候就无法使用移动旋转等
                Tools.current = Tool.None;
                //禁用默认的选择,这样就不会选中物体
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

                //绘制笔刷样式
                Handles.color = new Color(1,1,1,0.1f);
                Handles.DrawSolidDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.color = Color.red;
                Handles.DrawWireDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.DrawLine(hit.point, hit.point+(hit.normal* ArtBrushToolEW.ins.data.BrushSize / 2));




            }

        }
    }
}
#endif
